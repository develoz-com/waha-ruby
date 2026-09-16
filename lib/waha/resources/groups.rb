# frozen_string_literal: true

module Waha
  module Resources
    class Groups < Resource
      def list(session: nil, **query)
        name = session_name(session, "list_groups")
        transport.request(
          method: :get,
          path: "/api/#{segment(name)}/groups",
          operation: "list_groups",
          expected_status: 200,
          query: Support.query_hash(Support.compact_hash(query))
        )
      end

      def get(group_id:, session: nil)
        name = session_name(session, "get_group")
        transport.request(
          method: :get,
          path: "/api/#{segment(name)}/groups/#{segment(group_id)}",
          operation: "get_group",
          expected_status: 200
        )
      end
    end
  end
end
