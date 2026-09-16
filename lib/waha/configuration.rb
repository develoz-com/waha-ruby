# frozen_string_literal: true

module Waha
  DEFAULT_TIMEOUT = 30
  DEFAULT_SESSION = "default"

  # Process-wide defaults for Waha.client. Rails applications can set these in
  # an initializer; framework-neutral callers can pass keywords to Waha.client.
  # No client instances are cached here.
  Configuration = Struct.new(:base_url, :api_key, :session, :timeout) do
    def initialize(base_url: nil, api_key: nil, session: nil, timeout: nil)
      super(
        base_url || default_base_url,
        api_key || ENV.fetch("WAHA_API_KEY", nil),
        session || default_session,
        timeout || DEFAULT_TIMEOUT
      )
    end

    alias_method :session_name, :session
    alias_method :session_name=, :session=

    private

    def default_base_url
      ENV.fetch("WAHA_BASE_URL", nil) || ENV.fetch("WAHA_API_URL", nil)
    end

    def default_session
      ENV.fetch("WAHA_SESSION", nil) || ENV.fetch("WAHA_SESSION_NAME", nil) || DEFAULT_SESSION
    end
  end
end
