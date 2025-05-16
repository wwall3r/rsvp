import gleam/int
import gleam/string
import pog
import snag

pub fn pog_error_to_snag(error: pog.QueryError, layer: String) {
  error
  |> map_pog_error()
  |> snag.new()
  |> snag.layer(layer)
  |> Error()
}

// For what it's worth, I don't really like having to do this, despite how most
// of it is covered by the compiler (if the underlying library swaps the order of 
// string args we might be fucked though).
//
// I'd rather just be able to stringify anything like you can with `echo error`,
// however, I understand why that is difficult outside of dev (effectively the 
// types don't really exist after compilation; at least that's my understanding
// considering it compiles to Erlang).
//
// Another potential gripe: the pog lib should probably be responsible for providing 
// at least basic to_string functions for its types.
fn map_pog_error(error: pog.QueryError) {
  case error {
    pog.ConstraintViolated(message, constraint, detail) -> [
      message,
      constraint,
      detail,
    ]

    pog.PostgresqlError(code, name, message) -> [code, name, message]

    pog.UnexpectedArgumentCount(expected, got) -> [
      "Unexpected argument count. Expected "
      <> int.to_string(expected)
      <> " got "
      <> int.to_string(got),
    ]

    pog.UnexpectedArgumentType(expected, got) -> [
      "Unexpected argument type. Expected " <> expected <> " got " <> got,
    ]

    pog.UnexpectedResultType(_) -> ["Unexpected result type. Could not decode."]

    pog.QueryTimeout -> ["Query timeout"]

    pog.ConnectionUnavailable -> ["Connection unavailable"]
  }
  |> string.join(": ")
}
