# frozen_string_literal: true

require "openssl"

RSpec.describe Waha::Webhook do
  let(:body) { "{\"event\":\"message\"}" }
  let(:secret) { "webhook-secret" }
  let(:signature) { OpenSSL::HMAC.hexdigest("sha512", secret, body) }

  it "returns true for a valid sha512 signature" do
    expect(described_class.verify!(body:, signature:, algorithm: "sha512", secret:)).to be(true)
  end

  it "normalizes algorithm casing" do
    expect(described_class.verify!(body:, signature:, algorithm: " SHA512 ", secret:)).to be(true)
  end

  it "rejects attacker-selected algorithms" do
    bad_signature = OpenSSL::HMAC.hexdigest("sha256", secret, body)

    expect do
      described_class.verify!(body:, signature: bad_signature, algorithm: "sha256", secret:)
    end.to raise_error(Waha::VerificationError, /unsupported algorithm/)
  end

  it "rejects malformed signatures" do
    expect do
      described_class.verify!(body:, signature: "invalid", algorithm: "sha512", secret:)
    end.to raise_error(Waha::VerificationError, /malformed signature/)
  end

  it "rejects mismatched signatures without leaking body secret or signatures" do
    expected_length = OpenSSL::Digest.new("sha512").digest_length * 2
    mismatch = "a" * expected_length

    expect do
      described_class.verify!(body:, signature: mismatch, algorithm: "sha512", secret:)
    end.to raise_error(Waha::VerificationError, /signature mismatch/) { |error|
      expect(error.message).not_to include(body, signature, mismatch, secret)
    }
  end

  it "rejects non-hex same-length signatures" do
    expected_length = OpenSSL::Digest.new("sha512").digest_length * 2

    expect do
      described_class.verify!(body:, signature: "z" * expected_length, algorithm: "sha512", secret:)
    end.to raise_error(Waha::VerificationError, /malformed signature/)
  end

  it "fails closed when the secret is nil" do
    expect do
      described_class.verify!(body:, signature:, algorithm: "sha512", secret: nil)
    end.to raise_error(Waha::VerificationError, /secret is required/)
  end

  it "fails closed when the secret is empty" do
    expect do
      described_class.verify!(body:, signature:, algorithm: "sha512", secret: "")
    end.to raise_error(Waha::VerificationError, /secret is required/)
  end

  it "fails closed when the secret is blank" do
    expect do
      described_class.verify!(body:, signature:, algorithm: "sha512", secret: "  ")
    end.to raise_error(Waha::VerificationError, /secret is required/)
  end

  it "rejects an empty-key HMAC forgery attempt" do
    forged = OpenSSL::HMAC.hexdigest("sha512", "", body)

    expect do
      described_class.verify!(body:, signature: forged, algorithm: "sha512", secret: nil)
    end.to raise_error(Waha::VerificationError, /secret is required/)
  end
end
