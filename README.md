# waha-ruby

Framework-neutral Ruby client for the [WAHA](https://waha.dev/) WhatsApp HTTP API. It provides resource-oriented access to sessions, messages, media, chats, contacts, presence, webhooks, and explicit GOWS helpers, with an opt-in Rails adapter.

> `waha-ruby` is an independent community project, not an official WAHA project. WAHA is documented at [waha.dev](https://waha.dev/) and developed at [devlikeapro/waha](https://github.com/devlikeapro/waha). This gem links to the Apache-2.0 upstream project and does not copy its code.

## Requirements

- Ruby 4.0.5 or newer
- WAHA v2025.9 or a compatible WAHA HTTP API deployment
- An API key when the WAHA deployment requires one

The gem is tested against the declared v0.1 API surface. WAHA server versions can add or change response fields; the client returns parsed provider JSON without imposing a domain model.

## Installation

Add the gem to your application:

```ruby
gem "waha-ruby"
```

Then run `bundle install`. The only runtime dependency is `faraday`.

## Quick start

```ruby
require "waha"

client = Waha::Client.new(
  base_url: ENV.fetch("WAHA_BASE_URL"),
  api_key: ENV["WAHA_API_KEY"],
  session: ENV.fetch("WAHA_SESSION", "default")
)

client.sessions.list
client.messages.send_text(chat_id: "5511999999999@c.us", text: "Olá")
```

Every request uses the client's default session unless a resource method accepts an explicit `session:` override. Keep credentials in environment variables or a secret manager; do not commit them.

## API guide

The complete v0.1 resource map, argument conventions, raw return shapes, file payloads, errors, GOWS helpers, webhook verification, and Rails integration are in [docs/api.md](docs/api.md). For setup and secret handling, see [docs/installation.md](docs/installation.md).

## Security

The client sends `X-Api-Key` to WAHA and never logs credentials. Error details are bounded and redacted before they are placed in `Waha::Error` messages. Treat raw response hashes as untrusted provider data and redact message text, phone numbers, media URLs, and API keys before logging or persisting them. Webhook verification must run against the exact raw request body before JSON parsing.

## Development

```bash
asdf install
bundle install
bundle exec rspec path/to/spec.rb
bin/ci
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for quality rules and releases. See [CHANGELOG.md](CHANGELOG.md) for changes.

## License

MIT. See [LICENSE.txt](LICENSE.txt).
