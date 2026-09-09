# frozen_string_literal: true

require "uri"

module Waha
  module Resources
    class Media < Resource
      DOWNLOAD_TIMEOUT = 60
      LOOPBACK_HOSTS = %w[localhost 127.0.0.1 ::1].freeze

      def initialize(transport:, base_url:)
        super(transport:, session: nil)
        @base_url = base_url
      end

      def download(url:)
        transport.request(
          method: :get,
          path: resolved_url(url),
          operation: "download_media",
          expected_status: 200,
          headers: { "Content-Type" => nil },
          timeout: DOWNLOAD_TIMEOUT,
          response: :binary
        )
      end

      private

      def resolved_url(url)
        uri = parse_uri(url)

        unless uri.absolute?
          raise ValidationError.new(operation: "download_media", details: "media URL must be absolute")
        end
        unless uri.is_a?(URI::HTTP)
          raise ValidationError.new(operation: "download_media", details: "unsupported media URL scheme")
        end

        return rebase_to_base_url(uri) if LOOPBACK_HOSTS.include?(uri.host)

        unless uri.host == base_uri.host
          raise ValidationError.new(operation: "download_media", details: "media URL host is not the WAHA server")
        end

        uri.to_s
      end

      def rebase_to_base_url(uri)
        uri.scheme = base_uri.scheme
        uri.host = base_uri.host
        uri.port = base_uri.port
        uri.to_s
      end

      def base_uri
        @base_uri ||= URI.parse(@base_url.to_s)
      end

      def parse_uri(url)
        text = url.to_s
        uri = URI.parse(text)
        raise URI::InvalidURIError if text.include?("//") && uri.host.to_s.empty?

        uri
      rescue URI::InvalidURIError
        raise ValidationError.new(operation: "download_media", details: "invalid media URL")
      end
    end
  end
end
