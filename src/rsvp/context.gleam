import gleam/option.{type Option}
import pog.{type Connection}
import rsvp/models/users.{type User}

pub type Context {
  Context(
    db: Connection,
    nonce: String,
    static_path: String,
    user: Option(User),
  )
}
