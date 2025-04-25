import lustre/element/html
import rsvp/layouts

pub fn render() {
  html.div([], [])
  |> layouts.root_layout()
  |> layouts.to_html_response()
}
