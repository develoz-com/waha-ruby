# frozen_string_literal: true

require "openssl"

module Waha
  module Webhook
    DIGEST = "sha512"

    module_function

    def verify!(body:, signature:, algorithm:, secret:)
      verify_algorithm!(algorithm)
      signature_text = verified_signature_text(signature)
      expected = OpenSSL::HMAC.hexdigest(DIGEST, secret.to_s, body.to_s)
      return true if secure_compare?(signature_text, expected)

      raise VerificationError.new(operation: "verify_webhook", details: "signature mismatch")
    end

    def verify_algorithm!(algorithm)
      return if algorithm.to_s.strip.downcase == DIGEST

      raise VerificationError.new(operation: "verify_webhook", details: "unsupported algorithm")
    end
    private_class_method :verify_algorithm!

    def verified_signature_text(signature)
      text = signature.to_s
      expected_length = OpenSSL::Digest.new(DIGEST).digest_length * 2
      return text if text.length == expected_length && text.match?(/\A[0-9a-fA-F]+\z/)

      raise VerificationError.new(operation: "verify_webhook", details: "malformed signature")
    end
    private_class_method :verified_signature_text

    def secure_compare?(signature, expected)
      signature.bytesize == expected.bytesize && secure_bytes_equal?(signature, expected)
    end
    private_class_method :secure_compare?

    def secure_bytes_equal?(left, right)
      left_bytes = left.unpack("C*")
      right_bytes = right.unpack("C*")
      comparison = left_bytes.zip(right_bytes).reduce(0) { |result, pair| result | (pair[0] ^ pair[1]) }
      comparison.zero?
    end
    private_class_method :secure_bytes_equal?
  end
end
