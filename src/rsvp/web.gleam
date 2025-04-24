import rsvp/context.{type Context}
import wisp.{type Request, type Response}

pub fn middleware(
  req: wisp.Request,
  ctx: context.Context,
  handle_request: fn(Request, Context) -> Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/", from: ctx.static_path)

  handle_request(req, ctx)
}
