# frozen_string_literal: true

module Waha
  module Rails
    module SessionState
      CACHE_KEY_PREFIX = "waha:session_active"
      CACHE_TTL = 30

      module_function

      def active?(session_name: Waha.configuration.session_name)
        return false unless Waha.configured?

        ::Rails.cache.fetch(cache_key(session_name), expires_in: CACHE_TTL) do
          Waha.client(session: session_name).sessions.ready?
        end
      end

      def cache_key(session_name)
        "#{CACHE_KEY_PREFIX}:#{session_name}"
      end
    end
  end
end
