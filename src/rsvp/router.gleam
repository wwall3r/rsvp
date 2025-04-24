import gleam/http.{Get}
import lustre/attribute
import lustre/element
import lustre/element/html
import rsvp/web
import wisp.{type Response}

pub fn handle_request(req, ctx) {
  use req, _ctx <- web.middleware(req, ctx)

  let path = wisp.path_segments(req)
  let method = req.method

  case method, path {
    Get, [] -> home()
    _, _ -> wisp.not_found()
  }
}

fn home() -> Response {
  wisp.response(200)
  |> wisp.set_header("Content-Type", "text/html")
  |> wisp.html_body(
    // content
    html.div([], [])
    |> root_layout()
    |> element.to_document_string_tree(),
  )
}

fn root_layout(content: element.Element(a)) -> element.Element(a) {
  html.html([attribute.attribute("lang", "en")], [
    html.head([], [
      html.meta([attribute.charset("UTF-8")]),
      html.meta([
        attribute.name("viewport"),
        attribute.content("width=device-width, initial-scale=1.0"),
      ]),
      html.title([], "Title!"),
      // html.link([attribute.href("/priv/static/client.css")]),
    // html.script(
    //   [attribute.type_("module"), attribute.src("/priv/static/client.mjs")],
    //   "",
    // ),
    // html.script([
    //   attribute.src("/priv/static/lustre-server-component.mjs"),
    //   attribute.type_("module"),
    // ], []),
    // html.script([attribute.id("model"), attribute.type_("module")], init_json),
    ]),
    html.body([attribute.attribute("hx-boost", "true")], [
      html.div([attribute.id("app")], [content]),
    ]),
  ])
}
