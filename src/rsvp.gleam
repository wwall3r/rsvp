import dotenv_gleam
import gleam/erlang/process
import mist
import rsvp/config
import rsvp/context
import rsvp/router
import wisp
import wisp/wisp_mist

pub fn main() {
  dotenv_gleam.config()
  wisp.configure_logger()

  let port = config.load_port()
  let secret_key_base = config.load_secret_key_base()

  // let assert Ok(context) = context.new()
  let context = 42

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
