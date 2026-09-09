# frozen_string_literal: true

RSpec.describe Waha::Error do
  it "keeps operation status and bounded details" do
    error = described_class.new(operation: "send_text", status: 422, details: "x" * 1_000)

    expect(error).to have_attributes(operation: "send_text", status: 422)
    expect(error.details.length).to be <= 450
  end

  it "bounds the full message" do
    error = described_class.new(operation: "send_text", details: "x" * 1_000)

    expect(error.message.length).to be <= 600
  end

  it "redacts data URL payloads from details" do
    data_url = "data:image/png;base64,AAAA"
    error = Waha::ValidationError.new(operation: "send_image", details: "invalid #{data_url}")

    expect(error.message).not_to include(data_url)
    expect(error.message).to include("[REDACTED]")
  end

  it "uses safe defaults for validation failures" do
    error = Waha::ValidationError.new(operation: "send_text")

    expect(error.status).to be_nil
    expect(error.message).to include("unknown")
  end
end
