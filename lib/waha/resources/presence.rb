# frozen_string_literal: true

module Waha
  module Resources
    class Presence < Resource
      def subscribe(chat_id:, session: nil)
        name = session_name(session, "subscribe_presence")
        transport.request(
          method: :post,
          path: "/api/#{segment(name)}/presence/#{segment(chat_id)}/subscribe",
          operation: "subscribe_presence",
          expected_status: [200, 201]
        )
      end

      def list(session: nil)
        name = session_name(session, "list_presence")
        transport.request(
          method: :get,
          path: "/api/#{segment(name)}/presence",
          operation: "list_presence",
          expected_status: 200
        )
      end

      def get(chat_id:, session: nil)
        name = session_name(session, "get_presence")
        transport.request(
          method: :get,
          path: "/api/#{segment(name)}/presence/#{segment(chat_id)}",
          operation: "get_presence",
          expected_status: 200
        )
      end
    end
  end
end
