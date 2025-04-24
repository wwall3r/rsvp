import cigogne
import dotenv_gleam
import gleam/erlang/process
import gleam/result
import mist
import rsvp/config
import rsvp/context.{Context}
import rsvp/database
import rsvp/router
import wisp
import wisp/wisp_mist

pub fn main() {
  let _ = dotenv_gleam.config()
  wisp.configure_logger()

  let port = config.load_port()
  let secret_key_base = config.load_secret_key_base()
  let assert Ok(priv) = wisp.priv_directory("rsvp")
  let assert Ok(db_connection) = database.db_connect()
  let context = Context(db: db_connection, static_path: priv <> "/static")

  // migrate db if necessary
  cigogne.execute_migrations_to_last(db_connection)
  |> result.map_error(cigogne.print_error)
  |> result.unwrap_both()

  // The handle_request function is partially applied with the context to make
  // the request handler function that only takes a request.
  let handler = router.handle_request(_, context)

  let assert Ok(_) =
    handler
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  process.sleep_forever()
}
