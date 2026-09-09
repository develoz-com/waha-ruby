# frozen_string_literal: true

require "active_support/concern"

module Waha
  module Rails
    module ControllerConcern
      extend ActiveSupport::Concern

      private

      def verify_waha_webhook!
        raw_body = request.body.read
        Waha::Webhook.verify!(
          body: raw_body,
          signature: request.headers["X-Webhook-Hmac"],
          algorithm: request.headers["X-Webhook-Hmac-Algorithm"],
          secret: waha_webhook_secret
        )
      ensure
        request.body.rewind
      end

      def waha_webhook_secret
        configured_secret = ::Rails.application.config.waha.webhook_secret
        configured_secret.respond_to?(:call) ? configured_secret.call : configured_secret
      end
    end
  end
end
