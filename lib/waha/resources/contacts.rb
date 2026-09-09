# frozen_string_literal: true

module Waha
  module Resources
    class Contacts < Resource
      def list(session: nil, **query)
        transport.request(
          method: :get,
          path: "/api/contacts/all",
          operation: "list_contacts",
          expected_status: 200,
          query: Support.compact_hash(query.merge(session: session_name(session, "list_contacts")))
        )
      end

      def get(contact_id:, session: nil)
        transport.request(
          method: :get,
          path: "/api/contacts",
          operation: "get_contact",
          expected_status: 200,
          query: { session: session_name(session, "get_contact"), contactId: contact_id }
        )
      end

      def check_exists(phone:, session: nil)
        transport.request(
          method: :get,
          path: "/api/contacts/check-exists",
          operation: "check_contact_exists",
          expected_status: 200,
          query: { session: session_name(session, "check_contact_exists"), phone: }
        )
      end
    end
  end
end
