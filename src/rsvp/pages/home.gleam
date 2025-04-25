import lustre/element/html
import rsvp/layouts

pub fn render() {
  html.main([], [html.section([], [html.text("This is the home page")])])
  |> layouts.root_layout()
  |> layouts.to_html_response()
}
