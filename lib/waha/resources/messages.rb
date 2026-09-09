# frozen_string_literal: true

require "uri"

module Waha
  module Resources
    class Messages < Resource
      DATA_MEDIA_CHARS = "a-zA-Z0-9!/:[:space:]\u0023$&'()*+,;=?~_-"
      DATA_URL_PATTERN = Regexp.new("\\Adata:[#{DATA_MEDIA_CHARS}]*;base64,", Regexp::IGNORECASE)

      def send_text(chat_id:, text:, id: nil, reply_to: nil, session: nil)
        body = { session: session_name(session, "send_text"), chatId: chat_id, text: }
        body[:id] = id unless id.nil?
        body[:reply_to] = reply_to unless reply_to.nil?
        transport.request(
          method: :post,
          path: "/api/sendText",
          operation: "send_text",
          expected_status: 201,
          body:
        )
      end

      def edit(chat_id:, message_id:, text:, session: nil)
        name = session_name(session, "edit_message")
        transport.request(
          method: :put,
          path: message_path(name, chat_id, message_id),
          operation: "edit_message",
          expected_status: 200,
          body: { text: }
        )
      end

      def list(chat_id:, limit: 100, offset: nil, session: nil, **query)
        name = session_name(session, "list_messages")
        query = Support.query_hash(compact_hash(query.merge(limit:, offset:)))
        transport.request(
          method: :get,
          path: "/api/#{segment(name)}/chats/#{segment(chat_id)}/messages",
          operation: "list_messages",
          expected_status: 200,
          query:
        )
      end

      def find(chat_id:, message_id:, download_media: nil, session: nil)
        name = session_name(session, "find_message")
        transport.request(
          method: :get,
          path: message_path(name, chat_id, message_id),
          operation: "find_message",
          expected_status: 200,
          query: Support.query_hash(compact_hash(download_media:))
        )
      end

      def send_seen(chat_id:, message_ids: nil, session: nil)
        body = { session: session_name(session, "send_seen"), chatId: chat_id }
        body[:messageIds] = Array(message_ids) unless message_ids.nil?
        transport.request(
          method: :post,
          path: "/api/sendSeen",
          operation: "send_seen",
          expected_status: 201,
          body:
        )
      end

      def start_typing(chat_id:, session: nil)
        typing("start_typing", "startTyping", chat_id:, session:)
      end

      def stop_typing(chat_id:, session: nil)
        typing("stop_typing", "stopTyping", chat_id:, session:)
      end

      def new_message_id(session: nil)
        name = session_name(session, "new_message_id")
        transport.request(
          method: :get,
          path: "/api/#{segment(name)}/new-message-id",
          operation: "new_message_id",
          expected_status: 200
        )
      end

      def send_image(chat_id:, file:, mimetype:, filename: nil, caption: nil, reply_to: nil, session: nil)
        body = file_body("send_image", { chat_id:, file:, mimetype:, filename:, caption:, reply_to:, session: })
        transport.request(
          method: :post,
          path: "/api/sendImage",
          operation: "send_image",
          expected_status: 201,
          body:
        )
      end

      def send_file(chat_id:, file:, mimetype:, filename: nil, caption: nil, reply_to: nil, session: nil)
        body = file_body("send_file", { chat_id:, file:, mimetype:, filename:, caption:, reply_to:, session: })
        transport.request(
          method: :post,
          path: "/api/sendFile",
          operation: "send_file",
          expected_status: 201,
          body:
        )
      end

      def send_voice(chat_id:, file:, mimetype:, filename: nil, reply_to: nil, convert: nil, session: nil)
        body = file_body("send_voice", { chat_id:, file:, mimetype:, filename:, reply_to:, session: })
        body[:convert] = convert unless convert.nil?
        transport.request(
          method: :post,
          path: "/api/sendVoice",
          operation: "send_voice",
          expected_status: 201,
          body:
        )
      end

      private

      def file_body(operation, attributes)
        file_payload = file_payload(
          operation,
          file: attributes[:file],
          mimetype: attributes[:mimetype],
          filename: attributes[:filename]
        )
        Support.compact_hash(
          session: session_name(attributes[:session], operation),
          chatId: attributes[:chat_id],
          file: file_payload,
          caption: attributes[:caption],
          reply_to: attributes[:reply_to]
        )
      end

      def file_payload(operation, file:, mimetype:, filename:)
        raise ValidationError.new(operation:, details: "file must be a non-empty string") if file.to_s.empty?
        raise ValidationError.new(operation:, details: "mimetype is required") if mimetype.to_s.empty?

        payload = { mimetype: }
        payload[:filename] = filename unless filename.nil?

        if http_url?(file)
          payload.merge(url: file)
        elsif data_url?(file)
          payload.merge(data: file.split(",", 2).last)
        else
          raise ValidationError.new(operation:, details: "file must be an http(s) URL or data URL")
        end
      end

      def http_url?(value)
        uri = URI.parse(value.to_s)
        uri.is_a?(URI::HTTP) && !uri.host.to_s.empty?
      rescue URI::InvalidURIError
        false
      end

      def data_url?(value)
        DATA_URL_PATTERN.match?(value.to_s)
      end

      def typing(operation, endpoint, chat_id:, session:)
        transport.request(
          method: :post,
          path: "/api/#{endpoint}",
          operation:,
          expected_status: 201,
          body: { session: session_name(session, operation), chatId: chat_id }
        )
      end

      def message_path(session_name, chat_id, message_id)
        "/api/#{segment(session_name)}/chats/#{segment(chat_id)}/messages/#{segment(message_id)}"
      end

      def compact_hash(hash)
        Support.compact_hash(hash)
      end
    end
  end
end
