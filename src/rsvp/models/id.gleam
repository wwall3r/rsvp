import gleam/result
import youid/uuid

pub type Id(a) {
  Id(String)
}

pub fn from_uuid(value) {
  value
  |> uuid.to_string()
  |> Id()
}

pub fn to_uuid(value: Id(_)) {
  let Id(str) = value

  str
  |> uuid.from_string()
  |> result.unwrap(uuid.v4())
}
