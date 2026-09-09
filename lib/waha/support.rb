# frozen_string_literal: true

require "uri"

module Waha
  module Support
    module_function

    def segment(value)
      URI.encode_www_form_component(value.to_s).gsub("+", "%20")
    end

    def value(hash, key)
      return unless hash.is_a?(Hash)

      hash[key.to_s] || hash[key.to_sym]
    end

    QUERY_KEY_MAP = {
      download_media: "downloadMedia",
      sort_by: "sortBy",
      sort_order: "sortOrder",
      last_message_timestamp: "lastMessageTimestamp",
      last_message_id: "lastMessageId",
      contact_id: "contactId",
      phone_number: "phoneNumber"
    }.freeze

    def compact_hash(hash)
      hash.compact
    end

    def query_hash(hash)
      hash.each_with_object({}) do |(key, value), query|
        query[QUERY_KEY_MAP.fetch(key, key)] = value
      end
    end
  end
end
