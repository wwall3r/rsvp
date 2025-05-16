import gleam/bool
import gleam/http/request
import gleam/result
import gleam/string
import lustre/attribute
import wisp.{type Request, type Response}

/// sets the hx-post attribute
pub fn hx_post(url: String) {
  attribute.attribute("hx-post", url)
}

/// sets the hx-swap attribute
pub fn hx_swap(swap: String) {
  attribute.attribute("hx-swap", swap)
}

/// sets the hx-target attribute
pub fn hx_target(target: String) {
  attribute.attribute("hx-target", target)
}

/// If the request is an HTMX request, uses the `HX-Location` response header to
/// redirect the client via hx-boost.
///
/// Otherwise, sends a standard http redirect
pub fn redirect(redirect: String, req: Request) {
  case is_htmx_request(req) {
    True ->
      wisp.response(200)
      |> location(redirect)

    False -> wisp.redirect(redirect)
  }
}

pub fn location(response: Response, location: String) {
  wisp.set_header(response, "hx-location", location)
}

pub fn reswap(response: Response, value: String) {
  wisp.set_header(response, "hx-reswap", value)
}

pub fn retarget(response: Response, value: String) {
  wisp.set_header(response, "hx-retarget", value)
}

pub fn push_url(response: Response, value: String) {
  wisp.set_header(response, "hx-push-url", value)
}

/// whether or not the request is from HTMX
pub fn is_htmx_request(req: Request) {
  req
  |> request.get_header("hx-current-url")
  |> result.unwrap("")
  |> string.is_empty()
  |> bool.negate
}
