# frozen_string_literal: true

module Waha
  module Gows
    DIRECT_CHAT_ID_PATTERN = /\A\d+@c\.us\z/

    module MessageId
      RAW_PATTERN = /\A3EB0[0-9A-F]{18}\z/
      CANONICAL_PATTERN = /\Atrue_[^\s]+_3EB0[0-9A-F]{18}\z/

      module_function

      def valid_raw?(raw_id)
        raw_id.is_a?(String) && RAW_PATTERN.match?(raw_id)
      end

      def canonical(chat_id:, raw_id:)
        unless chat_id.is_a?(String) && !chat_id.empty?
          raise ValidationError.new(operation: "canonical_message_id", details: "chat_id is required")
        end
        unless valid_raw?(raw_id)
          raise ValidationError.new(operation: "canonical_message_id", details: "raw_id must be a valid GOWS id")
        end

        "true_#{chat_id}_#{raw_id}"
      end

      def valid_canonical?(message_id)
        return false unless message_id.is_a?(String)
        return false unless CANONICAL_PATTERN.match?(message_id)

        raw_id = message_id.to_s.split("_").last
        valid_raw?(raw_id)
      end
    end

    module_function

    def valid_direct_chat_id?(chat_id)
      chat_id.is_a?(String) && DIRECT_CHAT_ID_PATTERN.match?(chat_id)
    end

    class EditResponseValidator
      TARGET_ID_LENGTH = 22

      EDIT_MISSING_MESSAGE = "edit protocol response missing"
      TARGET_MISMATCH_MESSAGE = "edit protocol response targeted another message"
      TEXT_MISMATCH_MESSAGE = "edit protocol response text mismatch"

      def initialize(parsed_response:, message_id:, text:, status: nil)
        @parsed_response = parsed_response
        @message_id = message_id
        @text = text
        @status = status
      end

      def validate!
        protocol_message = extract_protocol_message
        raise_error!(EDIT_MISSING_MESSAGE) unless protocol_message.is_a?(Hash)

        raise_error!(TARGET_MISMATCH_MESSAGE) unless target_matches?(protocol_message)
        raise_error!(TEXT_MISMATCH_MESSAGE) unless text_matches?(protocol_message)

        @parsed_response
      end

      private

      def extract_protocol_message
        data = hash_value(@parsed_response, "_data")
        message = hash_value(data, "Message")
        raw_message = hash_value(data, "RawMessage")

        hash_value(message, "protocolMessage") || hash_value(raw_message, "protocolMessage")
      end

      def target_matches?(protocol_message)
        target_id = nested_value(protocol_message, "key", "ID")
        target_id.is_a?(String) &&
          target_id.length == TARGET_ID_LENGTH &&
          @message_id.to_s.end_with?(target_id)
      end

      def text_matches?(protocol_message)
        nested_value(protocol_message, "editedMessage", "extendedTextMessage", "text") == @text
      end

      def nested_value(value, *keys)
        keys.reduce(value) { |nested, key| hash_value(nested, key) }
      end

      def hash_value(value, key)
        return unless value.is_a?(Hash)

        value[key] || value[key.to_sym]
      end

      def raise_error!(details)
        raise ApiError.new(operation: "edit_message", status: @status, details:)
      end
    end
  end
end
