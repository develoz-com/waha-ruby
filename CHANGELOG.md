# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-09-16

### Added

- `Waha.configure`, `Waha.configuration`, `Waha.configured?`, and
  `Waha.client(session:, **overrides)` for opt-in process-wide defaults.
  Every call builds a fresh client; instances are never cached.
- `Waha.valid_chat_id?` for `@c.us`, `@g.us`, and `@lid` ids, plus
  `Waha.group_chat_id` to append the `@g.us` suffix when absent.
- `Waha::Resources::Chats#list` for `GET /api/{session}/chats`.
- `Waha::Resources::Groups` (`client.groups`) with `list` and `get`.
- `Waha::Resources::Sessions#update` (`PUT /api/sessions/{name}`).
- `Waha::Resources::Sessions#qr_data_url`, returning the QR PNG as a
  browser-ready `data:image/png;base64,` URL.
- `Waha::Resources::Sessions#ready?`, a WORKING-status predicate.
- `Waha::ServerError` (>= 500) and `Waha::RateLimitError` (429), plus
  `Waha::Error#retryable?` covering transport failures, 408, and 429.
- Opt-in Rails adapter `Waha::Rails::SessionState` (aliased as
  `Waha::SessionState`), which memoizes session readiness in `Rails.cache`.

### Changed

- `Waha::Resources::Messages#send_image`, `#send_file`, and `#send_voice`
  now accept `mimetype: nil`: the MIME type is read from the data URL prefix
  when omitted, and left out of the payload for remote URLs so WAHA can
  detect it.
- Text, media, seen, and typing requests accept both `200` and `201`
  responses across WAHA engines.
- `Waha::Resources::Sessions#qr` treats `format: "image"` as binary, not JSON.
- `Waha::Client` exposes `session`.

## [0.1.1] - 2026-09-09

### Fixed

- `Waha::Webhook.verify!` fails closed when the secret is nil, empty, or
  blank, preventing signature forgery against unconfigured consumers.
- Webhook comparison delegates to `OpenSSL.secure_compare` for native
  constant-time comparison.
- `Waha::Resources::Media#download` only accepts media URLs served by the
  configured WAHA host; all loopback origins (`localhost`, `127.0.0.1`,
  `::1`) rebase to the base URL, closing an SSRF and API-key exfiltration
  vector.
- `Waha::Resources::Webhooks` deep duplication uses identity-based
  memoization so value-equal config entries no longer alias each other.
- Chats message query keyword `last_message_id` maps to `lastMessageId`.

## [0.1.0] - 2026-09-09

### Added

- `Waha::Client` framework-agnostic SDK entry point with explicit
  `base_url`, `api_key`, and `session` configuration, powered by Faraday transport.
- Session lifecycle API: list, get, create, start, stop, restart, logout,
  destroy, and pairing (`qr`, `request_code`).
- Messaging API: send text/image/file/voice, edit message, mark chat seen,
  start/stop typing, new-message-id, canonical message id helpers, list and
  find messages.
- Media API: media download with localhost-to-base URL rebasing.
- Chats API: chat overview and chat message listing.
- Contacts API: contact lookup and `check-exists` number verification.
- Presence API: presence subscription per chat.
- Webhook configuration API: idempotent session webhook registration.
- `Waha::Webhook::Verifier` for sha512 HMAC webhook signature verification
  with constant-time comparison.
- Optional Rails adapter: controller concern for webhook verification and an
  install generator for the `waha.rb` initializer.
- Typed `Waha::Error` (operation, status, bounded redacted details) with
  provider payload redaction.
[Unreleased]: https://github.com/develoz-com/waha-ruby/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/develoz-com/waha-ruby/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/develoz-com/waha-ruby/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/develoz-com/waha-ruby/releases/tag/v0.1.0
