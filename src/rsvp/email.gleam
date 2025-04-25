import gleam/httpc
import rsvp/config
import wisp
import zeptomail.{Addressee}

pub fn send_email(
  from_name from_name: String,
  from_address from_address: String,
  to_name to_name: String,
  to_address to_address: String,
  body body: String,
  subject subject: String,
) {
  let key = config.zeptomail_api_key()
  let app_env = config.app_env()

  let email =
    zeptomail.Email(
      from: Addressee(from_name, from_address),
      to: [Addressee(to_name, to_address)],
      reply_to: [],
      cc: [],
      bcc: [],
      body: zeptomail.TextBody(body),
      subject: subject,
    )

  // log it in dev so we can see it
  case app_env, key {
    "dev", "" -> {
      echo email
      Ok(Nil)
    }
    _, _ -> send_over_api(email)
  }
}

const auth_email = "auth@mail.wallw.dev"

pub fn send_magic_link_email(address: String, token: String) {
  let app_name = config.app_name()
  let base_url = config.base_url()

  // sending a free-text, user-provided name in auth emails is a security risk, 
  // so do not add it to the subject or body
  let subject = "Login to " <> app_name
  let body =
    "Click the link below to log in to "
    <> app_name
    <> "\n\n"
    <> base_url
    <> "/login/"
    <> token
    <> "\n\nIf you did not request this email, you can safely ignore it."

  send_email(
    from_name: app_name,
    from_address: auth_email,
    // ditto here about the name
    to_name: "",
    to_address: address,
    body: body,
    subject: subject,
  )
}

fn send_over_api(email: zeptomail.Email) {
  let key = config.zeptomail_api_key()

  let response =
    zeptomail.email_request(email, key)
    |> httpc.send()

  case response {
    Ok(response) -> {
      let decoded = zeptomail.decode_email_response(response)

      case decoded {
        Ok(_) -> Ok(Nil)

        Error(zeptomail.ApiError(code, message, _details)) -> {
          wisp.log_error("Error sending email: " <> code <> " " <> message)
          Error(Nil)
        }

        Error(zeptomail.UnexpectedResponse(_)) -> {
          wisp.log_error("Error decoding email result json.")
          Error(Nil)
        }
      }
    }

    Error(err) -> {
      echo err
      wisp.log_error("http error sending email")
      Error(Nil)
    }
  }
}
