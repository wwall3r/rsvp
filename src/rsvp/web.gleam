import gleam/http.{method_to_string}
import gleam/int
import glotel/span
import glotel/span_kind
import rsvp/context.{type Context}
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

  handle_request(req, ctx)
}

// This appears to be set up properly but does not result in traces in jaeger
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

  echo "span created"
  echo span_ctx

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
