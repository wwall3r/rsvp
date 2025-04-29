import lustre/attribute
import lustre/element

pub fn icon(
  icon: String,
  attrs: List(attribute.Attribute(a)),
) -> element.Element(a) {
  element.element(
    "lucide-icon",
    [attribute.attribute("data-icon", icon), ..attrs],
    [],
  )
}
