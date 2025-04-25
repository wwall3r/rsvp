import lustre/element/html
import lustre/element.{Element}
import lustre/attribute
import rsvp/layouts

pub fn render() {
  html.main([attribute.class("container mx-auto px-4 py-8")], [
    // Hero section
    html.section([attribute.class("text-center py-12")], [
      html.h1(
        [attribute.class("text-4xl font-bold mb-4")],
        [html.text("A Fresh & Simple Take on RSVPs")],
      ),
      html.p(
        [attribute.class("text-xl mb-8 text-gray-600")],
        [html.text("Streamline your event planning with our hassle-free RSVP system")],
      ),
      html.div([attribute.class("mt-6")], [
        html.a(
          [
            attribute.class(
              "bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-6 rounded-lg mr-4",
            ),
            attribute.href("/create"),
          ],
          [html.text("Create Event")],
        ),
        html.a(
          [
            attribute.class(
              "bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-2 px-6 rounded-lg",
            ),
            attribute.href("/login"),
          ],
          [html.text("Sign In")],
        ),
      ]),
    ]),
    
    // Features section
    html.section([attribute.class("py-12")], [
      html.h2(
        [attribute.class("text-3xl font-bold text-center mb-8")],
        [html.text("Why Choose Our RSVP Platform?")],
      ),
      html.div([attribute.class("grid grid-cols-1 md:grid-cols-3 gap-8")], [
        feature_card(
          "Simple Setup",
          "Create your event in minutes with our intuitive interface",
        ),
        feature_card(
          "Real-time Responses",
          "Track RSVPs as they come in with instant notifications",
        ),
        feature_card(
          "Guest Management",
          "Easily manage your guest list and send reminders",
        ),
      ]),
    ]),
    
    // Call to action
    html.section([attribute.class("bg-gray-100 py-12 rounded-lg text-center")], [
      html.h2(
        [attribute.class("text-3xl font-bold mb-4")],
        [html.text("Ready to simplify your event planning?")],
      ),
      html.p(
        [attribute.class("text-xl mb-6 text-gray-600")],
        [html.text("Join thousands of hosts who've made their events stress-free")],
      ),
      html.a(
        [
          attribute.class(
            "bg-blue-500 hover:bg-blue-600 text-white font-bold py-3 px-8 rounded-lg inline-block",
          ),
          attribute.href("/signup"),
        ],
        [html.text("Get Started Free")],
      ),
    ]),
  ])
  |> layouts.root_layout()
  |> layouts.to_html_response()
}

fn feature_card(title: String, description: String) -> Element(a) {
  html.div([attribute.class("bg-white p-6 rounded-lg shadow-md")], [
    html.h3([attribute.class("text-xl font-bold mb-2")], [html.text(title)]),
    html.p([attribute.class("text-gray-600")], [html.text(description)]),
  ])
}
