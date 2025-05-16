//// Handles user tokens for various reasons
//// If this looks like it was translated from phoenix's `user_token.ex`, it was

import gleam/bit_array
import gleam/crypto
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import pog
import rsvp/models/id.{type Id, Id}
import rsvp/models/pog_utils.{pog_error_to_snag}
import rsvp/models/tokens/sql
import rsvp/models/users.{type User, User}
import snag

const rand_size = 32

pub type Token {
  Token(
    user_id: Id(User),
    token: BitArray,
    context: String,
    sent_to: Option(String),
  )
}

pub fn create_token(db: pog.Connection, token: Token) {
  let query =
    sql.create_token(
      db,
      token.user_id |> id.to_uuid(),
      token.token,
      token.context,
      token.sent_to |> option.unwrap(""),
    )

  case query {
    Ok(pog.Returned(1, [token_row])) ->
      Ok(Token(
        user_id: case token_row.user_id {
          Some(user_id) -> id.from_uuid(user_id)
          None -> Id("")
        },
        token: token_row.token,
        context: token_row.context,
        sent_to: Some(token_row.sent_to),
      ))

    Ok(pog.Returned(count, _)) ->
      snag.error(
        int.to_string(count) <> " tokens were created. Expected exactly one.",
      )

    Error(pog_error) ->
      pog_error_to_snag(
        pog_error,
        "Could not create token for " <> id.to_string(token.user_id),
      )
  }
}

/// Generates a token that will be stored in a signed place,
/// such as session or cookie. As they are signed, those
/// tokens do not need to be hashed.
///
/// The reason why we store session tokens in the database, even
/// though we already provides a session cookie, is because
/// our default session cookies are not persisted, they are
/// simply signed and potentially encrypted. This means they are
/// valid indefinitely, unless you change the signing/encryption
/// salt.
///
/// Therefore, storing them allows individual user
/// sessions to be expired. The token system can also be extended
/// to store additional data, such as the device used for logging in.
/// You could then use this information to display all valid sessions
/// and devices in the UI and allow users to explicitly expire any
/// session they deem invalid.
pub fn build_session_token(user: User) {
  let token = crypto.strong_random_bytes(rand_size)
  let str_token = bit_array.base64_url_encode(token, False)
  #(
    str_token,
    Token(token:, context: "session", user_id: user.id, sent_to: None),
  )
}

// Checks if the token is valid and returns its underlying lookup query.
//
// The query returns the user found by the token, if any.
//
// The token is valid if it matches the value in the database and it has
// not expired (after @session_validity_in_days).
pub fn verify_session_token(db: pog.Connection, str_token: String) {
  let token =
    str_token
    |> bit_array.base64_url_decode()
    |> result.unwrap(bit_array.from_string(""))

  case sql.verify_session_token(db, token) {
    Ok(pog.Returned(1, [user_row])) ->
      Ok(User(
        id: id.from_uuid(user_row.id),
        email: user_row.email,
        name: user_row.name,
      ))

    Ok(pog.Returned(count, _)) ->
      snag.error(
        int.to_string(count) <> " tokens were found. Expected exactly one.",
      )

    Error(pog_error) ->
      pog_error_to_snag(
        pog_error,
        "Could not verify session for token" <> str_token,
      )
  }
}

// Builds a token and its hash to be delivered to the user's email.
//
// The non-hashed token is sent to the user email while the
// hashed part is stored in the database. The original token cannot be reconstructed,
// which means anyone with read-only access to the database cannot directly use
// the token in the application to gain access. Furthermore, if the user changes
// their email in the system, the tokens sent to the previous email are no longer
// valid.
//
// Users can easily adapt the existing code to provide other types of delivery methods,
// for example, by phone numbers.
pub fn build_email_token(user: User, context: String) {
  build_hashed_token(user.id, context, user.email)
}

fn build_hashed_token(
  user_id: id.Id(users.User),
  context: String,
  sent_to: String,
) {
  let token = crypto.strong_random_bytes(rand_size)
  let hashed_token = crypto.hash(crypto.Sha256, token)

  #(
    bit_array.base64_url_encode(token, False),
    Token(
      token: hashed_token,
      context: context,
      sent_to: Some(sent_to),
      user_id: user_id,
    ),
  )
}

// Checks if the token is valid and returns its underlying lookup query.
//
// The query returns the user found by the token, if any.
//
// The given token is valid if it matches its hashed counterpart in the
// database and the user email has not changed. This function also checks
// if the token is being used within a certain period, depending on the
// context. 
pub fn verify_email_token(db: pog.Connection, token: String, context: String) {
  use decoded_token <- result.try(
    bit_array.base64_url_decode(token)
    |> result.map_error(fn(_) {
      snag.new("Could not decode token as base64 " <> token)
    }),
  )

  let hashed_token = crypto.hash(crypto.Sha256, decoded_token)
  case sql.verify_email_token(db, hashed_token, context) {
    Ok(pog.Returned(1, [user_row])) ->
      Ok(User(
        id: id.from_uuid(user_row.id),
        email: user_row.email,
        name: user_row.name,
      ))

    Ok(pog.Returned(count, _)) ->
      snag.error(
        int.to_string(count) <> " tokens were found. Expected exactly one.",
      )

    Error(pog_error) ->
      pog_error_to_snag(pog_error, "Could not verify email token " <> token)
  }
}
