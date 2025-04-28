import gleam/http.{Get}
import rsvp/pages/home
import rsvp/web
import wisp

pub fn handle_request(req, ctx) {
  use req, ctx <- web.middleware(req, ctx)

  let path = wisp.path_segments(req)
  let method = req.method

  case method, path {
    Get, [] -> home.render(req, ctx)
    _, _ -> wisp.not_found()
  }
}
