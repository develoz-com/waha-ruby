# frozen_string_literal: true

module Waha
  module Resources
    class Chats < Resource
      def overview(ids: nil, limit: nil, offset: nil, session: nil, **query)
        name = session_name(session, "chats_overview")
        transport.request(
          method: :get,
          path: "/api/#{segment(name)}/chats/overview",
          operation: "chats_overview",
          expected_status: 200,
          query: Support.query_hash(Support.compact_hash(query.merge(ids:, limit:, offset:)))
        )
      end

      def messages(chat_id:, limit: 100, offset: nil, session: nil, **query)
        name = session_name(session, "chat_messages")
        transport.request(
          method: :get,
          path: "/api/#{segment(name)}/chats/#{segment(chat_id)}/messages",
          operation: "chat_messages",
          expected_status: 200,
          query: Support.query_hash(Support.compact_hash(query.merge(limit:, offset:)))
        )
      end
    end
  end
end
