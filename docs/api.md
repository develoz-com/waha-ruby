# API guide

`waha-ruby` follows the v0.1 resource-oriented API. Methods return parsed JSON hashes/arrays from WAHA; the client does not wrap responses in gem-specific models.

## Client construction

```ruby
client = Waha::Client.new(
  base_url: "http://localhost:3000",
  api_key: ENV["WAHA_API_KEY"],
  session: "default"
)
```

`base_url` is required. `api_key` may be `nil` for deployments without API-key protection. `session` is the default session for resource calls. Use an explicit `session:` keyword on calls that support per-call routing; it overrides the constructor default and is not global mutable state. Calling a session-scoped method with no default session and no override raises `Waha::ValidationError`.

## Resources

The v0.1 client exposes these resource groups:

- `client.sessions`: `list`, `get`, `create`, `start`, `stop`, `restart`, `logout`, `destroy`, `qr`, and `request_code`.
- `client.messages`: `send_text`, `send_image`, `send_file`, `send_voice`, `edit`, `send_seen`, `start_typing`, `stop_typing`, `new_message_id`, `list`, and `find`.
- `client.media`: `download`.
- `client.chats`: `overview` and `messages`.
- `client.contacts`: `list`, `get`, and `check_exists`.
- `client.presence`: `subscribe`, `get`, and `list`.
- `client.webhooks`: `configure`.

Exact keyword signatures are defined by the shipped client classes and should be checked against the version in use. The resource methods intentionally return the provider's parsed JSON response. A successful call may therefore return a Hash, Array, String, Boolean, or `nil`, depending on the WAHA endpoint and response.

## File payloads

File endpoints accept a payload with a `file:` URL or data string and explicit metadata:

```ruby
client.messages.send_file(
  chat_id: "5511999999999@c.us",
  file: "data:application/pdf;base64,...",
  mimetype: "application/pdf",
  filename: "invoice.pdf"
)
```

Use an HTTPS URL or a `data:` URL. Do not pass local filesystem paths as if they were public URLs. Keep media URLs and message content out of logs.

## Errors

Failures raise subclasses of `Waha::Error`, a `StandardError` subclass with `operation`, `status`, and `details` readers:

- `Waha::ApiError` — WAHA returned an unexpected HTTP status or an unusable successful response.
- `Waha::TransportError` — network, timeout, or JSON transport failures.
- `Waha::ValidationError` — invalid client input (bad file payload, missing session, malformed URL).
- `Waha::VerificationError` — webhook HMAC verification failed.

```ruby
begin
  client.messages.send_text(chat_id: chat_id, text: text)
rescue Waha::Error => error
  warn "#{error.operation} failed (HTTP #{error.status})"
end
```

Rescue `Waha::Error` for expected WAHA/client failures. Rescue `StandardError` only at an application boundary where unexpected programming errors also require handling. Error messages are bounded and redacted: provider payloads and data URLs never appear in `details`.

## GOWS helpers

GOWS engine protocol helpers are explicit and opt-in. They are not automatically applied to message IDs or chat IDs.

```ruby
Waha::Gows::MessageId.valid_raw?("3EB0123456789012345678")
Waha::Gows::MessageId.canonical(chat_id: "5511999999999@c.us", raw_id: "3EB0123456789012345678")
# => "true_5511999999999@c.us_3EB0123456789012345678"
Waha::Gows::MessageId.valid_canonical?(message_id)
Waha::Gows.valid_direct_chat_id?("5511999999999@c.us")

validator = Waha::Gows::EditResponseValidator.new(
  parsed_response: response, message_id: message_id, text: new_text
)
validator.validate! # returns the response, or raises Waha::ApiError
```

Use them only when your application has a direct-chat/GOWS requirement. Group IDs are not silently treated as direct chats.

## Webhook HMAC verification

Verify the exact raw request body before parsing JSON. The verifier uses SHA-512 HMAC and constant-time comparison:

```ruby
Waha::Webhook.verify!(
  body: request.raw_post,
  signature: request.headers["X-Webhook-Hmac"],
  algorithm: request.headers["X-Webhook-Hmac-Algorithm"],
  secret: ENV.fetch("WAHA_WEBHOOK_HMAC_KEY")
)
```

`verify!` returns `true` or raises `Waha::VerificationError` (unsupported algorithm, malformed signature, or signature mismatch). Reject missing or invalid signatures. Never verify a re-serialized JSON body, and never log the secret or full webhook payload.

## Rails adapter

Rails is optional. The same gem includes an adapter and generator; applications that do not use Rails only need the framework-neutral client (`require "waha"` never loads Rails).

```bash
bin/rails generate waha:install
```

The generator creates the `waha.rb` initializer. The adapter provides a controller concern for webhook verification (`Waha::Rails::ControllerConcern` — a private `verify_waha_webhook!` suitable for `before_action`, reading `X-Webhook-Hmac` and `X-Webhook-Hmac-Algorithm`, rewinding the request body); it does not change the core client or configure routes automatically.

## WAHA compatibility

This gem targets WAHA's HTTP API and assumes a reachable WAHA server, supported session endpoints, and ordinary JSON responses. Authentication, session names, provider version compatibility, and operational limits remain WAHA deployment concerns. Consult the [official WAHA documentation](https://waha.dev/) and [Apache-2.0 source repository](https://github.com/devlikeapro/waha) for server behavior.