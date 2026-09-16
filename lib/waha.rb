# frozen_string_literal: true

require "waha/version"
require "waha/error"
require "waha/support"
require "waha/configuration"
require "waha/transport/faraday"
require "waha/resource"
require "waha/resources/sessions"
require "waha/resources/messages"
require "waha/resources/chats"
require "waha/resources/groups"
require "waha/resources/contacts"
require "waha/resources/presence"
require "waha/resources/webhooks"
require "waha/resources/media"
require "waha/gows"
require "waha/webhook"
require "waha/client"

module Waha
  CHAT_ID_PATTERN = /\A[\d-]+@(?:[cg]\.us|lid)\z/
  GROUP_CHAT_ID_SUFFIX = "@g.us"

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    # Resets configuration; primarily useful for tests and forked workers.
    def reset_configuration!
      @configuration = Configuration.new
    end

    def configured?
      !configuration.base_url.to_s.strip.empty?
    end

    # Builds a fresh client per call. Client instances are never cached so
    # per-request session overrides can never leak across callers.
    def client(session: nil, **overrides)
      Waha::Client.new(
        base_url: overrides.fetch(:base_url, configuration.base_url),
        api_key: overrides.fetch(:api_key, configuration.api_key),
        session: session || overrides.fetch(:session, configuration.session),
        timeout: overrides.fetch(:timeout, configuration.timeout)
      )
    end

    # True for contact (@c.us), group (@g.us), and lid (@lid) chat IDs.
    def valid_chat_id?(chat_id)
      !chat_id.to_s.strip.empty? && CHAT_ID_PATTERN.match?(chat_id.to_s)
    end

    # Appends the @g.us suffix when absent so bare numeric group IDs are usable.
    def group_chat_id(id)
      text = id.to_s
      text.end_with?(GROUP_CHAT_ID_SUFFIX) ? text : "#{text}#{GROUP_CHAT_ID_SUFFIX}"
    end
  end
end
