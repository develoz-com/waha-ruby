# Installation and configuration

## Install

Add the gem to the application Gemfile:

```ruby
gem "waha-ruby"
```

Run `bundle install`, then require the gem:

```ruby
require "waha"
```

The core client is framework-neutral. Rails support is included in the gem but is opt-in at application level.

## Configure the client

```ruby
Waha::Client.new(
  base_url: ENV.fetch("WAHA_BASE_URL"),
  api_key: ENV["WAHA_API_KEY"],
  session: ENV.fetch("WAHA_SESSION", "default")
)
```

Use the WAHA server's reachable base URL. Do not use a browser-only hostname from a different network namespace. `api_key` may be omitted only when the server is configured without API-key authentication.

For Rails, run:

```bash
bin/rails generate waha:install
```

Review the generated initializer and provide values through encrypted credentials or environment variables. The generator does not create routes or enable webhook handling automatically.

## Webhooks

Set the webhook secret in a secret manager or environment variable and verify `request.raw_post` before parsing JSON. See [the API guide](api.md#webhook-hmac-verification).

## Configuration safety

- Never commit API keys or webhook secrets.
- Avoid logging raw response hashes; they may contain message text, phone numbers, media URLs, or provider metadata.
- The gem bounds and redacts error details, but application logs and persistence remain your responsibility.
- Use explicit per-call `session:` overrides when one process serves multiple WAHA sessions.
