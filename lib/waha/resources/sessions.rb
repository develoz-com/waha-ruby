# frozen_string_literal: true

module Waha
  module Resources
    class Sessions < Resource
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
        transport.request(
          method: :post,
          path: "/api/sessions",
          operation: "create_session",
          expected_status: [200, 201],
          body: Support.compact_hash(name:, start:, config:)
        )
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
        response_format = format.nil? ? :binary : :json
        transport.request(
          method: :get,
          path: "/api/#{segment(name)}/auth/qr",
          operation: "session_qr",
          expected_status: 200,
          query: Support.compact_hash(format: format),
          response: response_format
        )
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
