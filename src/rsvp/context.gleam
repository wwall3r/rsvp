import pog.{type Connection}

pub type Context {
  Context(db: Connection, static_path: String)
}
