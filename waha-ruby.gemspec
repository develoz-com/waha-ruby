# frozen_string_literal: true

require_relative "lib/waha/version"

Gem::Specification.new do |spec|
  spec.name = "waha-ruby"
  spec.version = Waha::VERSION
  spec.authors = ["Mauricio Zaffari"]
  spec.email = ["mauriciozaffari@gmail.com"]

  spec.summary = "Ruby client for the WAHA WhatsApp HTTP API."
  spec.description = "Waha::Client is a framework-neutral Ruby SDK for WAHA (WhatsApp HTTP API): sessions, " \
                     "messaging, media, chats, contacts, presence, webhook HMAC verification, and an optional Rails adapter."
  spec.homepage = "https://github.com/develoz-com/waha-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |file|
      (file == gemspec) ||
        file.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ docs/ templates/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |file| File.basename(file) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 2.0"

  spec.add_development_dependency "bundler-audit", "~> 0.9"
  spec.add_development_dependency "flay", "~> 2.14"
  spec.add_development_dependency "rack", "~> 3.1"
  spec.add_development_dependency "railties", "~> 8.1"
  spec.add_development_dependency "reek", "~> 6.3"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rubocop", "~> 1.65"
  spec.add_development_dependency "rubocop-performance", "~> 1.21"
  spec.add_development_dependency "rubocop-rspec", "~> 3.0"
  spec.add_development_dependency "rubocop-rubycw", "~> 0.1.6"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "simplecov-lcov", "~> 0.8"
  spec.add_development_dependency "webmock", "~> 3.23"
end
