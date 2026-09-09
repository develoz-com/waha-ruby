# frozen_string_literal: true

require "openssl"

module Waha
  module Webhook
    DIGEST = "sha512"

    module_function

    def verify!(body:, signature:, algorithm:, secret:)
      if secret.to_s.strip.empty?
        raise VerificationError.new(operation: "verify_webhook", details: "secret is required")
      end

      verify_algorithm!(algorithm)
      signature_text = verified_signature_text(signature)
      expected = OpenSSL::HMAC.hexdigest(DIGEST, secret.to_s, body.to_s)
      return true if OpenSSL.secure_compare(signature_text, expected)

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
  end
end
