import lustre/attribute
import lustre/element
import lustre/element/html
import wisp

pub fn root_layout(content: element.Element(a)) -> element.Element(a) {
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
    html.body([attribute.attribute("hx-boost", "true")], [content]),
  ])
}

pub fn to_html_response(content: element.Element(a)) {
  wisp.response(200)
  |> wisp.set_header("Content-Type", "text/html")
  |> wisp.html_body(
    content
    |> element.to_document_string_tree(),
  )
}
