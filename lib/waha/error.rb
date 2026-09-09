# frozen_string_literal: true

module Waha
  class Error < StandardError
    MESSAGE_LIMIT = 600
    DETAILS_LIMIT = 450

    attr_reader :operation, :status, :details

    def initialize(operation:, status: nil, details: nil)
      @operation = operation.to_s.slice(0, 80)
      @status = status
      @details = sanitize(details)
      super(build_message.slice(0, MESSAGE_LIMIT))
    end

    private

    def sanitize(details)
      text = details.to_s
      text = "operation failed" if text.empty?
      text.gsub(%r{data:[^\s,;]+;base64,[A-Za-z0-9+/=]+}i, "[REDACTED]")
          .slice(0, DETAILS_LIMIT)
    end

    def build_message
      status_text = status.nil? ? "unknown" : status
      "WAHA #{operation} failed (status #{status_text}): #{details}"
    end
  end

  class ApiError < Error; end
  class TransportError < Error; end
  class ValidationError < Error; end
  class VerificationError < Error; end
end
