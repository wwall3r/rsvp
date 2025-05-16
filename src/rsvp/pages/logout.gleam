import gleam/http.{Delete, Get, Post}
import rsvp/context.{type Context}
import rsvp/htmx
import rsvp/web
import wisp.{type Request}

pub fn handle_request(req: Request, ctx: Context) {
  use req, _ctx <- web.require_auth(req, ctx)

  // If you were really hardcore into correct http responses, you'd probably only
  // allow delete here. However, I don't give a shit other than making sure that
  // typical header-only requests like HEAD or OPTIONS aren't allowed.
  case req.method {
    Get -> logout(req)
    Post -> logout(req)
    Delete -> logout(req)
    _ -> wisp.not_found()
  }
}

fn logout(req: Request) {
  // to log out we just expire the cookie and redirect to home
  htmx.redirect("/", req)
  |> wisp.set_cookie(req, web.get_session_cookie_name(), "", wisp.Signed, -1)
}
