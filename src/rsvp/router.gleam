import gleam/http.{Get}
import gleam/string
import rsvp/context.{type Context}
import rsvp/pages/home
import rsvp/web
import wisp.{type Response}

const content_security_policy = "script-src 'self' 'nonce-{nonce}';
style-src 'nonce-{nonce}'
object-src 'none';
base-uri 'none';
frame-src 'self';
default-src 'self';
require-trusted-types-for 'script';"

pub fn handle_request(req, ctx) {
  use req, ctx <- web.middleware(req, ctx)

  let path = wisp.path_segments(req)
  let method = req.method

  case method, path {
    Get, [] -> home.render(req, ctx)
    _, _ -> wisp.not_found()
  }
  |> wisp.set_header("Content-Security-Policy", content_security_policy)
  |> add_content_security_policy(ctx)
}

fn add_content_security_policy(response: Response, ctx: Context) {
  let policy_with_nonce =
    content_security_policy
    |> string.replace("{nonce}", ctx.nonce)

  response
  |> wisp.set_header("Content-Security-Policy", policy_with_nonce)
}
