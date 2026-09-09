# frozen_string_literal: true

RSpec.describe Waha::Client do
  let(:transport) { SpecTransport::Fake.new }

  it "exposes lazy resource accessors built from the injected transport" do
    client = described_class.new(base_url: "http://waha.test", api_key: "key", session: "default", transport:)

    expect(client.sessions).to equal(client.sessions)
    expect(client.messages).to be_a(Waha::Resources::Messages)
    expect(client.webhooks).to be_a(Waha::Resources::Webhooks)
  end

  it "builds the default HTTParty transport when none is injected" do
    client = described_class.new(base_url: "http://waha.test", api_key: "key")

    response = { "name" => "default" }
    stub_request(:get, "http://waha.test/api/sessions/")
      .to_return(status: 200, body: response.to_json, headers: { "Content-Type" => "application/json" })

    expect(client.sessions.list).to be_a(Array).or be_a(Hash).or be_nil
  end
end
