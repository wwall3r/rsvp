import gleam/http.{Get}
import lustre/element/html
import rsvp/context.{type Context}
import rsvp/layouts
import rsvp/web
import wisp.{type Request}

pub fn handle_request(req: Request, ctx: Context) {
  use req, ctx <- web.require_auth(req, ctx)

  let path = wisp.path_segments(req)
  let method = req.method

  case method, path {
    Get, ["events"] -> render(req, ctx)
    _, _ -> wisp.not_found()
  }
}

pub fn render(req: Request, ctx: Context) {
  [html.h1([], [html.text("Events")])]
  |> layouts.nav_layout(req, ctx)
  |> layouts.root_layout(ctx, "Events")
  |> layouts.to_html_response()
}
