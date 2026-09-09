# frozen_string_literal: true

RSpec.describe Waha::Gows::MessageId do
  it "recognizes valid raw GOWS ids" do
    expect(described_class.valid_raw?("3EB0123456789012345678")).to be(true)
    expect(described_class.valid_raw?("bad")).to be(false)
    expect(described_class.valid_raw?(nil)).to be(false)
  end

  it "builds and validates canonical ids without accepting malformed forms" do
    canonical = described_class.canonical(chat_id: "15551234567@c.us", raw_id: "3EB0123456789012345678")

    expect(canonical).to eq("true_15551234567@c.us_3EB0123456789012345678")
    expect(described_class.valid_canonical?(canonical)).to be(true)
    expect(described_class.valid_canonical?("true_x_3EB0123")).to be(false)
  end

  it "raises validation errors for missing chat or invalid raw ids" do
    expect do
      described_class.canonical(chat_id: "", raw_id: "3EB0123456789012345678")
    end.to raise_error(Waha::ValidationError, /chat_id is required/)
    expect do
      described_class.canonical(chat_id: "chat", raw_id: "private")
    end.to raise_error(Waha::ValidationError, /valid GOWS id/)
  end
end

RSpec.describe Waha::Gows::EditResponseValidator do
  def fixture(name)
    JSON.parse(File.read(File.join(__dir__, "../fixtures/#{name}")))
  end

  it "validates documented edit protocol responses and returns the parsed response" do
    response = fixture("waha_edit_message_response.json")
    validator = described_class.new(
      parsed_response: response,
      message_id: "true_15551234567@c.us_3EB0123456789012345678",
      text: "Done"
    )

    expect(validator.validate!).to eq(response)
  end

  it "accepts the RawMessage protocol fallback" do
    response = fixture("waha_edit_raw_message_response.json")

    expect do
      described_class.new(
        parsed_response: response,
        message_id: "true_15551234567@c.us_3EB0123456789012345678",
        text: "Done"
      ).validate!
    end.not_to raise_error
  end

  it "raises bounded errors without exposing target ids or edited text" do
    response = fixture("waha_edit_message_response.json")
    response["_data"]["Message"]["protocolMessage"]["key"]["ID"] = "3EB0999999999999999999"

    expect do
      described_class.new(
        parsed_response: response,
        message_id: "true_15551234567@c.us_3EB0123456789012345678",
        text: "Done",
        status: 200
      ).validate!
    end.to raise_error(Waha::ApiError, /targeted another message/) { |error|
      expect(error.message).not_to include("3EB0123456789012345678", "3EB0999999999999999999", "Done")
      expect(error.message.length).to be <= 600
    }
  end

  it "raises when the successful response lacks protocol data" do
    expect do
      described_class.new(parsed_response: { "id" => "x" }, message_id: "id", text: "text").validate!
    end.to raise_error(Waha::ApiError, /missing/)
  end
end
