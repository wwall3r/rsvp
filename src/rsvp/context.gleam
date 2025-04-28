import pog.{type Connection}

pub type Context {
  Context(db: Connection, nonce: String, static_path: String)
}
