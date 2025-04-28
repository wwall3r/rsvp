import lustre/attribute
import lustre/element
import lustre/element/html
import rsvp/context.{type Context}
import wisp.{type Request}

pub fn root_layout(
  content: List(element.Element(a)),
  ctx: Context,
  page_title: String,
) -> element.Element(a) {
  html.html([attribute.attribute("lang", "en")], [
    html.head([], [
      html.meta([attribute.charset("UTF-8")]),
      html.meta([
        attribute.name("viewport"),
        attribute.content("width=device-width, initial-scale=1.0"),
      ]),
      html.title([], page_title),
      html.link([
        attribute.nonce(ctx.nonce),
        attribute.rel("preconnect"),
        attribute.href("https://api.fonts.coollabs.io"),
        attribute.crossorigin("anonymous"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/assets/css/pico.jade.min.css"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/assets/css/index.css"),
      ]),
      html.script([attribute.src("/assets/js/htmx.min.js")], ""),
    ]),
    html.body([attribute.attribute("hx-boost", "true")], content),
  ])
}

pub fn nav_layout(content: List(element.Element(a)), req: Request, ctx: Context) {
  [
    html.header([attribute.class("container")], [
      html.nav([], [
        html.ul([], [
          html.li([], [
            html.a([attribute.href("/")], [html.strong([], [html.text("RSVP")])]),
          ]),
        ]),
        html.ul([], [
          html.li([], [html.a([attribute.href("/login")], [html.text("Login")])]),
        ]),
      ]),
    ]),
    html.main([attribute.class("container")], content),
  ]
}

pub fn to_html_response(content: element.Element(a)) {
  wisp.response(200)
  |> wisp.set_header("Content-Type", "text/html")
  |> wisp.html_body(
    content
    |> element.to_document_string_tree(),
  )
}
