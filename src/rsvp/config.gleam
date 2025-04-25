import envoy
import gleam/int
import gleam/result
import gleam/string
import wisp

pub fn app_name() {
  envoy.get("APP_NAME")
  |> result.unwrap("RSVP")
}

pub fn app_env() {
  envoy.get("APP_ENV")
  |> result.unwrap("dev")
}

pub fn base_url() {
  case app_env() {
    "dev" ->
      envoy.get("BASE_URL")
      |> result.unwrap("http://localhost:" <> int.to_string(port()))

    _ -> get_or_warn("BASE_URL")
  }
}

pub fn secret_key_base() {
  get_or_panic("SECRET_KEY_BASE")
}

pub fn database_url() {
  get_or_panic("DATABASE_URL")
}

pub fn zeptomail_api_key() {
  get_or_warn("ZEPTOMAIL_API_KEY")
}

pub fn port() {
  envoy.get("PORT")
  |> result.then(int.parse)
  |> result.unwrap(8080)
}

fn get_or_warn(env_var: String) {
  let value =
    envoy.get(env_var)
    |> result.unwrap("")

  case value {
    "" -> {
      "env var "
      |> string.append(env_var)
      |> string.append(" is not set!")
      |> wisp.log_critical()

      ""
    }

    v -> v
  }
}

fn get_or_panic(env_var: String) {
  let value = get_or_warn(env_var)

  case value {
    "" -> panic
    v -> v
  }
}
