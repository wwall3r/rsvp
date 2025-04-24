import envoy
import gleam/int
import gleam/result
import gleam/string
import wisp

pub fn load_secret_key_base() -> String {
  get_or_panic("SECRET_KEY_BASE")
}

pub fn load_database_url() -> String {
  get_or_panic("DATABASE_URL")
}

pub fn load_port() -> Int {
  envoy.get("PORT")
  |> result.then(int.parse)
  |> result.unwrap(8080)
}

fn get_or_panic(env_var: String) -> String {
  let value =
    envoy.get(env_var)
    |> result.unwrap("")

  case value {
    "" -> {
      "env var "
      |> string.append(env_var)
      |> string.append(" is not set!")
      |> wisp.log_critical()

      panic
    }

    v -> v
  }
}
