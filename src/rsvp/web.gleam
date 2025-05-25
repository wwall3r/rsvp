import gleam/bit_array
import gleam/crypto
import gleam/http.{method_to_string}
import gleam/http/request
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/uri
import glotel/span
import glotel/span_kind
import rsvp/context.{type Context, Context}
import rsvp/htmx
import rsvp/models/tokens
import wisp.{type Request, type Response}

pub fn middleware(
  req: Request,
  ctx: Context,
  handle_request: fn(Request, Context) -> Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/", from: ctx.static_path)
  use req, ctx <- trace_middleware(req, ctx)
  use ctx <- add_nonce_to_context(ctx)
  use _, ctx <- add_user_to_context(req, ctx)

  handle_request(req, ctx)
}

const session_cookie_name = "_rsvp_session"

pub fn get_session_cookie_name() {
  session_cookie_name
}

fn add_user_to_context(
  req: Request,
  ctx: Context,
  handle_request: fn(Request, Context) -> Response,
) {
  let user =
    req
    |> wisp.get_cookie(session_cookie_name, wisp.Signed)
    |> result.unwrap("")
    |> tokens.verify_session_token(ctx.db, _)
    |> result.map(Some)
    |> result.unwrap(None)

  let ctx = Context(..ctx, user:)

  handle_request(req, ctx)
}

pub fn require_auth(
  req: Request,
  ctx: Context,
  handle_request: fn(Request, Context) -> Response,
) {
  case ctx.user {
    Some(_) -> handle_request(req, ctx)
    None ->
      req
      |> get_login_redirect()
      |> htmx.redirect(req)
  }
}

pub fn require_anon(
  req: Request,
  ctx: Context,
  handle_request: fn(Request, Context) -> Response,
) {
  case ctx.user {
    None -> handle_request(req, ctx)
    _ -> htmx.redirect(get_redirect(req), req)
  }
}

pub fn get_login_redirect(req: Request) {
  let redirect_uri = request.to_uri(req)

  let redirect =
    uri.Uri(..redirect_uri, scheme: None, host: None, port: None)
    |> uri.to_string()

  "/login?" <> uri.query_to_string([#("r", redirect)])
}

fn add_nonce_to_context(
  ctx: Context,
  handler: fn(Context) -> Response,
) -> Response {
  let message = crypto.strong_random_bytes(32)

  let nonce =
    crypto.hash(crypto.Sha512, message)
    |> bit_array.base16_encode()
    |> string.slice(0, 32)

  let ctx = Context(..ctx, nonce: nonce)

  handler(ctx)
}

fn trace_middleware(
  request: Request,
  ctx: Context,
  handler: fn(Request, Context) -> Response,
) -> Response {
  let method = method_to_string(request.method)
  let path = request.path

  span.extract_values(request.headers)

  use span_ctx <- span.new_of_kind(span_kind.Server, method <> " " <> path, [
    #("http.method", method),
    #("http.route", path),
  ])

  let response = handler(request, ctx)

  span.set_attribute(
    span_ctx,
    "http.status_code",
    int.to_string(response.status),
  )

  case response.status >= 500 {
    True -> span.set_error(span_ctx)
    _ -> Nil
  }

  response
}

pub fn get_redirect(req: Request) {
  req
  |> get_query_param("r")
  |> redirect_validator()
}

/// This prevents anyone from sending a link with an external redirect
/// such as https://evil.com
pub fn redirect_validator(input: String) {
  let default = "/events"

  case input {
    // scheme-relative paths are not valid
    "//" <> _ -> default

    // logging in just to redirect to logout is kinda nutty
    "/logout" <> _ -> default

    // any relative path is valid
    "/" <> _ -> input

    // otherwise just redirect to the events page
    _ -> default
  }
}

pub fn get_query_param(req: Request, key: String) {
  req.query
  |> option.unwrap("")
  |> uri.parse_query()
  |> result.unwrap([])
  |> list.key_find(key)
  |> result.unwrap("")
}
