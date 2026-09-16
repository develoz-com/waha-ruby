# frozen_string_literal: true

module Waha
  class Error < StandardError
    MESSAGE_LIMIT = 600
    DETAILS_LIMIT = 450

    RETRYABLE_STATUSES = [408, 429].freeze

    attr_reader :operation, :status, :details

    def initialize(operation:, status: nil, details: nil)
      @operation = operation.to_s.slice(0, 80)
      @status = status
      @details = sanitize(details)
      super(build_message.slice(0, MESSAGE_LIMIT))
    end

    # Retryable failures: transport problems, WAHA server errors, rate limits, timeouts.
    def retryable?
      is_a?(ServerError) || is_a?(RateLimitError) || is_a?(TransportError) ||
        RETRYABLE_STATUSES.include?(status)
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
  class ServerError < ApiError; end
  class RateLimitError < ApiError; end
  class TransportError < Error; end
  class ValidationError < Error; end
  class VerificationError < Error; end
end
