import lustre/attribute
import lustre/element/html
import rsvp/context.{type Context}
import rsvp/layouts
import wisp.{type Request}

pub fn render(req: Request, ctx: Context) {
  [
    // Hero section
    html.article([attribute.class("")], [
      html.h1([], [html.text("A Fresh & Simple Take on RSVPs")]),
      html.p([attribute.class("")], [
        html.text(
          "Streamline your event planning with a hassle-free RSVP system for both you and your guests",
        ),
      ]),
      html.footer([attribute.class("")], [
        html.a([attribute.role("button"), attribute.href("/create")], [
          html.text("Create Event"),
        ]),
      ]),
    ]),
  ]
  |> layouts.nav_layout(req, ctx)
  |> layouts.root_layout("RSVP")
  |> layouts.to_html_response()
}
