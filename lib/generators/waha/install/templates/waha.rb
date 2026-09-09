# frozen_string_literal: true

# Keep WAHA credentials in the application environment. The factory creates a
# fresh client for each caller, so session-specific state is never shared.
Rails.application.config.waha.client_factory = lambda do |session: ENV.fetch("WAHA_SESSION")|
  Waha::Client.new(
    base_url: ENV.fetch("WAHA_BASE_URL"),
    api_key: ENV.fetch("WAHA_API_KEY"),
    session: session
  )
end

# Used by Waha::Rails::ControllerConcern#verify_waha_webhook!.
Rails.application.config.waha.webhook_secret = -> { ENV.fetch("WAHA_WEBHOOK_HMAC_KEY") }
