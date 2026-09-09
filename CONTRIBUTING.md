# Contributing

Contributions must keep the public API explicit, framework-neutral, and compatible with the declared v0.1 contract. Do not add runtime dependencies without a concrete API need.

## Setup

This repository uses [asdf](https://asdf-vm.com/) and `.tool-versions`.

```bash
asdf install
ruby --version
bundle install
```

`bin/setup` is a convenience wrapper for `bundle install`.

Run focused tests while working:

```bash
bundle exec rspec spec/path/to/spec.rb
```

Before submitting, run the complete repository gate:

```bash
bin/ci
```

`bin/ci` runs RSpec, RuboCop, Reek on `lib`, Flay with mass threshold 150 on `lib`, and Bundler Audit. Do not add exclusions to silence warnings in new code. Fix the design or update a rule only when it reflects an established project convention.

Use double-quoted Ruby strings and frozen string literals. Keep changes within the owned surface for the task; runtime API and API specs require their own focused review.

## Documentation

Update `README.md` for concise user-facing navigation and `docs/api.md` for signatures, return behavior, configuration, and security details. Do not copy upstream WAHA code. Link to the official Apache-2.0 project instead.

## Release setup

RubyGems trusted publishing requires no long-lived token:

1. Create a GitHub environment named `rubygems` with no secrets.
2. Add a pending trusted publisher for gem `waha-ruby` on RubyGems with owner `develoz-com`, repository `waha-ruby`, workflow `release.yml`, and environment `rubygems`.
3. Keep the repository's release workflow pinned to the reviewed action SHAs.

## Release process

1. Bump `Waha::VERSION` in `lib/waha/version.rb` and add user-facing changes under `Unreleased` in `CHANGELOG.md`.
2. Run `bin/ci` and review the package contents with `gem build waha-ruby.gemspec`.
3. Merge to `main`.
4. Publish a stable GitHub Release tagged `vX.Y.Z` at the current `main` commit.
5. Let `release.yml` validate the tag, build and inspect the exact gem, publish through RubyGems OIDC, verify API visibility/SHA, and finalize `CHANGELOG.md`.

Prereleases are not supported. If publication succeeds but changelog finalization fails, rerun the same workflow; do not create another tag or publish a second version.
