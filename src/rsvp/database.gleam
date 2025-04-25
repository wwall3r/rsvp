import gleam/dynamic/decode
import gleam/result
import pog
import rsvp/config

pub fn db_connect() -> Result(pog.Connection, Nil) {
  let db_url = config.database_url()

  case ensure_db_exists(db_url) {
    Error(_) -> panic as "Database does not exist and could not be created!"
    _ -> Nil
  }

  use db_config <- result.try(pog.url_config(db_url))
  Ok(pog.connect(db_config))
}

/// Ensures the DB is created. I do this because it is really handy to be able
/// to specify `DATABASE_URL=postgres://user:pass@host:5432/$COOLIFY_URL` in Coolify
/// (my deployment software), so that review apps automatically created for PRs 
/// get a fresh DB. This allows PRs to be tested with DB isolation regarding their
/// migrations.
fn ensure_db_exists(db_url: String) {
  // there is probably a shorter way to do this, but...
  use db_config <- result.try(pog.url_config(db_url))

  // connect to the root posgres instance without a DB name
  let db =
    db_config
    |> pog.database("")
    |> pog.pool_size(1)
    |> pog.connect()

  // see if the db exists
  let sql_query = "select datname from pg_database WHERE datname = $1"

  let row_decoder = {
    use name <- decode.field(0, decode.string)
    decode.success(name)
  }

  let response =
    sql_query
    |> pog.query()
    |> pog.parameter(pog.text(db_config.database))
    |> pog.returning(row_decoder)
    |> pog.execute(db)

  case response {
    Ok(q) if q.count == 1 -> Ok("DB exists")
    _ -> {
      let sql_query = "create database " <> db_config.database
      let db_result =
        sql_query
        |> pog.query()
        |> pog.execute(db)

      case db_result {
        Ok(_) -> Ok("DB created")
        Error(_) -> Error(Nil)
      }
    }
  }
}
