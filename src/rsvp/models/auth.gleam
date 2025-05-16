import gleam/result
import pog
import rsvp/email
import rsvp/models/tokens
import rsvp/models/users
import snag

pub fn email_user_with_magic_link(
  db: pog.Connection,
  email: String,
  redirect: String,
) {
  use user <- result.try(
    db
    |> users.get_user_by_email(email)
    |> result.try_recover(fn(_) { users.create_user(db, email, "") })
    |> snag.context("Could not get or create user"),
  )

  let #(to_email, token) = tokens.build_email_token(user, "login")

  use _created_token <- result.try(
    db
    |> tokens.create_token(token)
    |> snag.context("could not create token"),
  )

  use email_result <- result.try(
    email.send_token_email(email, to_email, redirect)
    |> snag.context("Could not send token email"),
  )

  Ok(email_result)
}
