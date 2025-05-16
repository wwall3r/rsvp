import gleam/http.{Get, Post}
import gleam/list
import gleam/result
import gleam/uri
import lustre/attribute
import lustre/element/html
import rsvp/components/core
import rsvp/context.{type Context}
import rsvp/htmx
import rsvp/layouts
import rsvp/models/tokens
import rsvp/utils
import rsvp/web
import snag
import wisp.{type Request}

pub fn handle_request(req: Request, ctx: Context) {
  use req, ctx <- web.require_anon(req, ctx)

  let path = wisp.path_segments(req)
  let method = req.method

  case method, path {
    Get, ["token", token] -> render_token(req, ctx, token)
    Post, ["token"] -> handle_submit(req, ctx)
    Get, ["token", ..] -> render_invalid(req, ctx)
    _, _ -> wisp.not_found()
  }
}

type TokenForm {
  TokenForm(token: String, redirect: String, errors: List(String))
}

fn render_token(req: Request, ctx: Context, token: String) {
  let defaults = TokenForm(token:, redirect: web.get_redirect(req), errors: [])

  [html.article([], [token_form(defaults)])]
  |> layouts.nav_layout(req, ctx)
  |> layouts.root_layout(ctx, "Login - RSVP")
  |> layouts.to_html_response()
}

fn token_form(form: TokenForm) {
  html.form(
    [
      attribute.method("POST"),
      attribute.action("/token"),
      htmx.hx_post("/token"),
      htmx.hx_swap("outerHTML"),
      htmx.hx_target("this"),
    ],
    [
      html.p([], [html.text("Welcome Back!")]),
      html.input([
        attribute.type_("hidden"),
        attribute.name("redirect"),
        attribute.value(form.redirect),
      ]),
      html.input([
        attribute.type_("hidden"),
        attribute.name("token"),
        attribute.value(form.token),
      ]),
      html.ul(
        [],
        form.errors
          |> list.map(fn(err) { html.li([], [html.text(err)]) }),
      ),
      html.button([attribute.type_("submit")], [
        html.text("Continue "),
        core.icon("log-in", []),
      ]),
    ],
  )
}

fn handle_submit(req: Request, ctx: Context) {
  use formdata <- wisp.require_form(req)

  let redirect =
    formdata.values
    |> list.key_find("redirect")
    |> result.unwrap("")
    |> web.redirect_validator()

  let token =
    formdata.values
    |> list.key_find("token")
    |> result.unwrap("")

  use user <- utils.try_and_map_error(
    tokens.verify_email_token(ctx.db, token, "login"),
    fn(snag) {
      // TODO: gotta get this on the otel trace
      wisp.log_error(snag.pretty_print(snag))

      case htmx.is_htmx_request(req) {
        True ->
          redirect
          |> invalid("The provided link was invalid or has expired.")
          |> layouts.to_html_status(422)

        False ->
          // TODO: show errors somehow?
          wisp.redirect("/token?" <> uri.query_to_string([#("r", redirect)]))
      }
    },
  )

  let #(str_token, token) = tokens.build_session_token(user)

  use _token <- utils.try_and_map_error(
    tokens.create_token(ctx.db, token),
    fn(snag) {
      // TODO: gotta get this on the otel trace
      wisp.log_error(snag.pretty_print(snag))

      case htmx.is_htmx_request(req) {
        True ->
          redirect
          |> invalid("Could not create session. Please try again later.")
          |> layouts.to_html_status(422)

        False ->
          wisp.redirect("/token?" <> uri.query_to_string([#("r", redirect)]))
      }
    },
  )

  redirect
  |> htmx.redirect(req)
  |> wisp.set_cookie(
    req,
    web.get_session_cookie_name(),
    str_token,
    wisp.Signed,
    30 * 24 * 60 * 60,
  )
}

fn invalid(redirect: String, error: String) {
  html.div([], [
    html.p([], [html.text(error)]),
    html.a(
      [
        attribute.role("button"),
        attribute.href("/login?" <> uri.query_to_string([#("r", redirect)])),
      ],
      [html.text("Try Again "), core.icon("log-in", [])],
    ),
  ])
}

fn render_invalid(req: Request, ctx: Context) {
  [
    html.article([], [
      req
      |> web.get_redirect()
      |> invalid("The provided link was invalid or has expired."),
    ]),
  ]
  |> layouts.nav_layout(req, ctx)
  |> layouts.root_layout(ctx, "Login - RSVP")
  |> layouts.to_html_response()
}
