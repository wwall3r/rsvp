import gleam/result
import pog
import rsvp/email
import rsvp/models/tokens
import rsvp/models/users
import wisp

pub fn email_user_with_magic_link(
  db: pog.Connection,
  email: String,
  redirect: String,
) {
  let user =
    db
    |> users.get_user_by_email(email)
    |> result.try_recover(fn(_) { users.create_user(db, email, "") })

  case user {
    Ok(user) -> {
      let #(email_token, token) = tokens.build_email_token(user, "login")

      db
      |> tokens.create_token(token)
      |> result.map_error(fn(_) { Nil })
      |> result.map(fn(_) {
        email.send_token_email(email, email_token, redirect)
      })
    }

    err -> {
      echo err
      wisp.log_error("could not get or create user")
      Error(Nil)
    }
  }
}
