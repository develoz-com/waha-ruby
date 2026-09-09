# frozen_string_literal: true

module Waha
  class Resource
    def initialize(transport:, session:)
      @transport = transport
      @session = session
    end

    private

    attr_reader :transport

    def session_name(override, operation)
      value = override || @session
      return value unless value.nil? || value.to_s.empty?

      raise ValidationError.new(operation:, details: "session is required")
    end

    def segment(value)
      transport.escape_path_segment(value)
    end
  end
end
