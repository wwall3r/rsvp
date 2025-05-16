import gleam/int
import pog
import rsvp/models/id.{type Id}
import rsvp/models/pog_utils.{pog_error_to_snag}
import rsvp/models/users/sql
import snag

pub type User {
  User(id: Id(User), email: String, name: String)
}

pub fn create_user(db: pog.Connection, email email: String, name name: String) {
  case sql.create_user(db, email, name) {
    Ok(pog.Returned(1, [user_row])) ->
      Ok(User(
        id: id.from_uuid(user_row.id),
        email: user_row.email,
        name: user_row.name,
      ))

    Ok(pog.Returned(count, _)) ->
      snag.error(
        int.to_string(count) <> " users were created. Expected exactly one.",
      )

    Error(pog_error) ->
      pog_error_to_snag(pog_error, "Could not create user with email " <> email)
  }
}

pub fn get_user(db: pog.Connection, user_id: Id(User)) {
  case sql.get_user_by_id(db, user_id |> id.to_uuid()) {
    Ok(pog.Returned(1, [user_row])) ->
      Ok(User(
        id: id.from_uuid(user_row.id),
        email: user_row.email,
        name: user_row.name,
      ))

    Ok(pog.Returned(count, _)) ->
      snag.error(
        int.to_string(count)
        <> " users were returned via id. Expected exactly one.",
      )

    Error(pog_error) ->
      pog_error_to_snag(
        pog_error,
        "Could not get user by id " <> id.to_string(user_id),
      )
  }
}

pub fn get_user_by_email(db: pog.Connection, email: String) {
  case sql.get_user_by_email(db, email) {
    Ok(pog.Returned(1, [user_row])) ->
      Ok(User(
        id: id.from_uuid(user_row.id),
        email: user_row.email,
        name: user_row.name,
      ))

    Ok(pog.Returned(count, _)) ->
      snag.error(
        int.to_string(count)
        <> " users were returned via email. Expected exactly one.",
      )

    Error(pog_error) ->
      pog_error_to_snag(pog_error, "Could not get user by email " <> email)
  }
}

pub fn update_user(db: pog.Connection, user: User) {
  let user_id = user.id |> id.to_uuid()

  case sql.update_user(db, user_id, user.name, user.email) {
    Ok(pog.Returned(1, [user_row])) ->
      // this is getting old, I need to go look further into Gleam's generics
      Ok(User(
        id: id.from_uuid(user_row.id),
        email: user_row.email,
        name: user_row.name,
      ))

    Ok(pog.Returned(count, _)) ->
      snag.error(
        int.to_string(count) <> " users were updated. Expected exactly one.",
      )

    Error(pog_error) ->
      pog_error_to_snag(
        pog_error,
        "Could not update user " <> id.to_string(user.id),
      )
  }
}
