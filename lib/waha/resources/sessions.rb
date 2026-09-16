# frozen_string_literal: true

require "base64"

module Waha
  module Resources
    class Sessions < Resource
      WORKING_STATUS = "WORKING"

      def list(all: nil)
        transport.request(
          method: :get,
          path: "/api/sessions/",
          operation: "list_sessions",
          expected_status: 200,
          query: Support.compact_hash(all: all)
        )
      end

      def get(session: nil)
        name = session_name(session, "get_session")
        transport.request(
          method: :get,
          path: "/api/sessions/#{segment(name)}",
          operation: "get_session",
          expected_status: 200
        )
      end

      def create(name:, start: nil, config: nil)
        write_session("create_session", :post, "/api/sessions", { name:, start:, config: })
      end

      def update(session: nil, name: nil, config: nil)
        session_key = session_name(session, "update_session")
        write_session("update_session", :put, "/api/sessions/#{segment(session_key)}",
                      { name: name || session_key, config: })
      end

      def start(session: nil)
        action("start_session", "start", session:)
      end

      def stop(session: nil)
        action("stop_session", "stop", session:)
      end

      def restart(session: nil)
        action("restart_session", "restart", session:)
      end

      def logout(session: nil)
        action("logout_session", "logout", session:, body: {})
      end

      def destroy(session: nil)
        name = session_name(session, "delete_session")
        transport.request(
          method: :delete,
          path: "/api/sessions/#{segment(name)}",
          operation: "delete_session",
          expected_status: [200, 204]
        )
      end

      def qr(format: nil, session: nil)
        name = session_name(session, "session_qr")
        transport.request(
          method: :get,
          path: "/api/#{segment(name)}/auth/qr",
          operation: "session_qr",
          expected_status: 200,
          query: Support.compact_hash(format: format),
          response: qr_response_format(format)
        )
      end

      # PNG bytes rendered as a browser-ready data URL.
      def qr_data_url(session: nil)
        png = qr(format: "image", session:)
        "data:image/png;base64,#{Base64.strict_encode64(png.to_s)}"
      end

      # WAHA reports WORKING for an authenticated, usable session.
      def ready?(session: nil)
        Support.value(get(session:), "status") == WORKING_STATUS
      rescue Waha::Error
        false
      end

      def request_code(phone_number:, method: nil, session: nil)
        name = session_name(session, "request_code")
        transport.request(
          method: :post,
          path: "/api/#{segment(name)}/auth/request-code",
          operation: "request_code",
          expected_status: [200, 201],
          body: Support.compact_hash(phoneNumber: phone_number, method: method)
        )
      end

      private

      def write_session(operation, method, path, body)
        transport.request(method:, path:, operation:, expected_status: [200, 201], body: Support.compact_hash(body))
      end

      def qr_response_format(format)
        format.to_s == "image" || format.nil? ? :binary : :json
      end

      def action(operation, action, session:, body: nil)
        name = session_name(session, operation)
        transport.request(
          method: :post,
          path: "/api/sessions/#{segment(name)}/#{action}",
          operation:,
          expected_status: [200, 201],
          body:
        )
      end
    end
  end
end
