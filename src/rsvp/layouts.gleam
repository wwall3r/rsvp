import gleam/option.{None, Some}
import lustre/attribute
import lustre/element
import lustre/element/html
import rsvp/components/core
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
      html.script([attribute.src("/assets/js/index.js")], ""),
    ]),
    html.body([attribute.attribute("hx-boost", "true")], content),
  ])
}

pub fn nav_layout(
  content: List(element.Element(a)),
  _req: Request,
  ctx: Context,
) {
  [
    html.header([attribute.class("container")], [
      html.nav([], [
        html.ul([], [
          html.li([], [
            html.a([attribute.href("/")], [html.strong([], [html.text("RSVP")])]),
          ]),
        ]),
        html.ul([], case ctx.user {
          Some(_user) -> [
            html.li([], [
              html.a([attribute.href("/events")], [html.text("Events")]),
            ]),
            html.li([], [
              html.a([attribute.href("/logout")], [html.text("Logout")]),
            ]),
          ]

          None -> [
            html.li([], [
              html.a([attribute.href("/login")], [
                core.icon("log-in", []),
                html.text(" Login"),
              ]),
            ]),
          ]
        }),
      ]),
    ]),
    html.main([attribute.class("container")], content),
  ]
}

pub fn to_html_response(content: element.Element(a)) {
  to_html_status(content, 200)
}

pub fn to_html_status(content: element.Element(a), status: Int) {
  wisp.response(status)
  |> wisp.set_header("Content-Type", "text/html")
  |> wisp.string_body(
    content
    |> element.to_string(),
  )
}
