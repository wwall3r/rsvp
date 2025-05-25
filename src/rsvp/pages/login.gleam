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
import rsvp/models/auth
import rsvp/utils
import rsvp/web
import valid/experimental as valid
import wisp.{type Request}

pub fn handle_request(req: Request, ctx: Context) {
  use req, ctx <- web.require_anon(req, ctx)

  let path = wisp.path_segments(req)
  let method = req.method

  case method, path {
    Get, ["login"] -> render_login(req, ctx)
    Post, ["login"] -> handle_submit(req, ctx)
    Get, ["login", "instructions"] -> render_instructions(req, ctx)
    _, _ -> wisp.not_found()
  }
}

type LoginForm {
  LoginForm(email: String, redirect: String, errors: List(String))
}

fn render_login(req: Request, ctx: Context) {
  let defaults =
    LoginForm(email: "", redirect: web.get_redirect(req), errors: [])

  [html.article([], [login_form(defaults)])]
  |> layouts.nav_layout(req, ctx)
  |> layouts.root_layout(ctx, "Login - RSVP")
  |> layouts.to_html_response()
}

fn login_form(form: LoginForm) {
  let aria_invalid = case form.email, form.errors {
    "", [] -> ""
    _, [] -> "false"
    _, _ -> "true"
  }

  html.form(
    [
      attribute.method("POST"),
      attribute.action("/login"),
      htmx.hx_post("/login"),
      htmx.hx_swap("outerHTML"),
      htmx.hx_target("this"),
    ],
    [
      html.input([
        attribute.type_("hidden"),
        attribute.name("redirect"),
        attribute.value(form.redirect),
      ]),
      html.input([
        // how many times can we mark one field as email?
        attribute.name("email"),
        attribute.type_("email"),
        attribute.value(form.email),
        attribute.required(True),
        attribute.placeholder("Email"),
        attribute.aria_label("Email"),
        attribute.aria_invalid(aria_invalid),
      ]),
      html.ul(
        [],
        form.errors
          |> list.map(fn(err) { html.li([], [html.text(err)]) }),
      ),
      html.button([attribute.type_("submit")], [
        core.icon("send", []),
        html.text(" Send a login link"),
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

  let email =
    formdata.values
    |> list.key_find("email")
    |> result.unwrap("")

  use email <- utils.try_or_return(email_validator(email), fn(errors) {
    case htmx.is_htmx_request(req) {
      True ->
        LoginForm(email:, errors:, redirect:)
        |> login_form()
        |> layouts.to_html_status(422)

      False ->
        // TODO: show errors somehow?
        wisp.redirect("/login?" <> uri.query_to_string([#("r", redirect)]))
    }
  })

  use _ <- utils.try_or_return(
    auth.email_user_with_magic_link(ctx.db, email, redirect),
    utils.get_snag_handler(ctx, case htmx.is_htmx_request(req) {
      True ->
        LoginForm(email:, redirect:, errors: [
          "Could not create user. Please try again later",
        ])
        |> login_form()
        |> layouts.to_html_status(422)

      False ->
        // TODO: show errors somehow?
        wisp.redirect("/login?" <> uri.query_to_string([#("r", redirect)]))
    }),
  )

  case htmx.is_htmx_request(req) {
    True ->
      instructions()
      |> layouts.to_html_response()

    False ->
      wisp.redirect(
        "/login/instructions?" <> uri.query_to_string([#("email", email)]),
      )
  }
}

fn instructions() {
  html.div([], [
    html.h1([], [core.icon("mail", []), html.text(" Link Sent")]),
    html.p([], [html.text("Click the link in your email to log in.")]),
  ])
}

fn render_instructions(req: Request, ctx: Context) {
  [html.article([], [instructions()])]
  |> layouts.nav_layout(req, ctx)
  |> layouts.root_layout(ctx, "Login - RSVP")
  |> layouts.to_html_response()
}

fn email_validator(input: String) {
  input
  |> valid.validate(check_email)
}

fn check_email(input: String) {
  // TODO: the validator here is rather simple. Maybe keep looking for a better one?
  use result <- valid.check(
    input,
    valid.string_is_email("Please enter a valid email"),
  )
  valid.ok(result)
}
