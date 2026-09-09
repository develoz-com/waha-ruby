# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-09-09

### Added

- `Waha::Client` framework-agnostic SDK entry point with explicit
  `base_url`, `api_key`, and `session` configuration.
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