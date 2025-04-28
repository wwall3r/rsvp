import gleam/bit_array
import gleam/crypto
import gleam/http.{method_to_string}
import gleam/int
import gleam/string
import gleam/yielder
import glotel/span
import glotel/span_kind
import rsvp/context.{type Context, Context}
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

  handle_request(req, ctx)
}

fn add_nonce_to_context(
  ctx: Context,
  handler: fn(Context) -> Response,
) -> Response {
  let message = random_string(32)

  let nonce =
    crypto.hash(crypto.Sha512, <<message:utf8>>)
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

fn random_string(length: Int) -> String {
  let chars =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:,.<>?"
  let char_count = string.length(chars)

  yielder.range(0, length)
  |> yielder.map(fn(_) {
    let index = int.random(char_count - 1)
    string.slice(chars, index, 1)
  })
  |> yielder.to_list
  |> string.concat
}
