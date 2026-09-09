# frozen_string_literal: true

require "json"
require "uri"
require "httparty"

module Waha
  module Transport
    class HttpParty
      JSON_HEADERS = { "Content-Type" => "application/json" }.freeze

      def initialize(base_url:, api_key:, timeout:)
        @base_url = base_url.to_s.delete_suffix("/")
        @api_key = api_key
        @timeout = timeout
      end

      def request(**call_attributes)
        operation = call_attributes.fetch(:operation)
        response = validated_response_mode(call_attributes[:response] || :json)
        http_response = dispatch_request(call_attributes)
        verify_status!(http_response, call_attributes.fetch(:expected_status), operation)
        parse_response(http_response, response, operation)
      rescue Waha::Error
        raise
      rescue JSON::GeneratorError, JSON::ParserError
        raise TransportError.new(operation:, details: "invalid JSON response")
      rescue StandardError => e
        raise TransportError.new(operation:, details: "transport failure (#{e.class})")
      end

      def escape_path_segment(value)
        URI.encode_www_form_component(value.to_s).gsub("+", "%20")
      end

      private

      def dispatch_request(call_attributes)
        ::HTTParty.public_send(
          call_attributes.fetch(:method),
          request_url(call_attributes.fetch(:path)),
          **request_options(call_attributes)
        )
      end

      def validated_response_mode(response)
        return response if %i[json binary].include?(response)

        raise ValidationError.new(operation: "request", details: "unsupported response mode")
      end

      def request_options(call_attributes)
        options = {
          headers: default_headers.merge(call_attributes[:headers] || {}).compact,
          timeout: call_attributes[:timeout] || @timeout
        }
        body = call_attributes[:body]
        query = call_attributes[:query]
        options[:body] = JSON.generate(body) unless body.nil?
        options[:query] = query unless query.nil? || query.empty?
        options
      end

      def default_headers
        JSON_HEADERS.merge(
          "X-Api-Key" => @api_key,
          "User-Agent" => "waha-ruby/#{Waha::VERSION}"
        )
      end

      def request_url(path)
        text = path.to_s
        uri = URI.parse(text)
        return uri.to_s if uri.absolute?

        raise URI::InvalidURIError unless text.start_with?("/")
        raise URI::InvalidURIError if text.start_with?("//")

        "#{@base_url}#{text}"
      rescue URI::InvalidURIError
        raise ValidationError.new(operation: "request", details: "invalid request URL")
      end

      def verify_status!(response, expected_status, operation)
        return if Array(expected_status).include?(response.code)

        details = response.body.to_s.empty? ? "empty provider error response" : "[REDACTED]"
        raise ApiError.new(operation:, status: response.code, details:)
      end

      def parse_response(response, format, operation)
        return response.body if format == :binary
        return nil if response.body.to_s.strip.empty?

        JSON.parse(response.body)
      rescue JSON::ParserError
        raise TransportError.new(operation:, status: response.code, details: "invalid JSON response")
      end
    end
  end
end
