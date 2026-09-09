# frozen_string_literal: true

module Waha
  module Resources
    class Webhooks < Resource
      def initialize(transport:, session:, sessions:)
        super(transport:, session:)
        @sessions = sessions
      end

      def configure(url:, events:, hmac_secret: nil, retries: nil, session: nil)
        name = session_name(session, "configure_webhook")
        session_data = @sessions.get(session: name)
        config = session_config(session_data)
        desired_config = config_with_webhook(config, url:, events:, hmac_secret:, retries:)
        return :unchanged if desired_config == config

        put_session(name, session_name_value(session_data, name), desired_config)
        :updated
      end

      private

      def session_config(session_data)
        config = Support.value(session_data, "config")
        unless config.is_a?(Hash)
          raise ApiError.new(operation: "configure_webhook", details: "session response is missing config")
        end

        config
      end

      def config_with_webhook(config, url:, events:, hmac_secret:, retries:)
        webhooks = Array(Support.value(config, "webhooks"))
        index = webhooks.index { |webhook| matching_webhook?(webhook, url) }
        kept = webhooks.reject { |webhook| matching_webhook?(webhook, url) }
        kept.insert(index || kept.length, desired_webhook(url:, events:, hmac_secret:, retries:))
        deep_dup(config).merge("webhooks" => kept)
      end

      def matching_webhook?(webhook, url)
        webhook.is_a?(Hash) && webhook["url"] == url
      end

      def desired_webhook(url:, events:, hmac_secret:, retries:)
        webhook = { "url" => url, "events" => Array(events).map(&:to_s) }
        webhook["hmac"] = { "key" => hmac_secret } unless hmac_secret.nil?
        webhook["retries"] = retries unless retries.nil?
        webhook
      end

      def put_session(session_name, name, config)
        transport.request(
          method: :put,
          path: "/api/sessions/#{segment(session_name)}",
          operation: "configure_webhook",
          expected_status: 200,
          body: { name:, config: }
        )
      end

      def session_name_value(session_data, fallback)
        Support.value(session_data, "name") || fallback
      end

      def deep_dup(value, seen = {})
        return value unless value.is_a?(Hash) || value.is_a?(Array)
        return seen[value] if seen.key?(value)

        copy = value.is_a?(Hash) ? {} : []
        seen[value] = copy
        copy_dup_children(value, copy, seen)
      end

      def copy_dup_children(value, copy, seen)
        if value.is_a?(Hash)
          value.each { |key, nested| copy[key] = deep_dup(nested, seen) }
        else
          value.each { |nested| copy << deep_dup(nested, seen) }
        end
        copy
      end
    end
  end
end
