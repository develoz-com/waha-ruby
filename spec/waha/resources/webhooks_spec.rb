# frozen_string_literal: true

RSpec.describe Waha::Resources::Webhooks do
  let(:transport) { SpecTransport::Fake.new }
  let(:sessions) { Waha::Resources::Sessions.new(transport:, session: "default") }
  let(:resource) { described_class.new(transport:, session: "team/a b", sessions:) }
  let(:url) { "https://app.test/webhooks/waha" }
  let(:session_data) do
    {
      "name" => "team/a b",
      "config" => {
        "metadata" => { "owner" => "pitwall" },
        "webhooks" => [
          { "url" => "https://other.test/hook", "events" => ["session.status"] },
          { "url" => url, "events" => ["old"] }
        ]
      }
    }
  end

  it "replaces a matching webhook URL while preserving unrelated config" do
    transport.instance_variable_set(:@responses, [session_data, {}])

    result = resource.configure(url:, events: %w[message], hmac_secret: "hmac-secret", retries: { "attempts" => 2 })
    put_request = transport.requests.find { |request| request.method == :put }
    webhooks = put_request.body[:config]["webhooks"]

    expect(result).to eq(:updated)
    expect(put_request.body[:config]["metadata"]).to eq("owner" => "pitwall")
    expect(webhooks.first).to eq("url" => "https://other.test/hook", "events" => ["session.status"])
  end

  it "writes the desired webhook payload" do
    transport.instance_variable_set(:@responses, [session_data, {}])
    resource.configure(url:, events: "message", hmac_secret: "hmac-secret", retries: { "attempts" => 2 })

    webhook = transport.requests.last.body[:config]["webhooks"].last
    expect(webhook).to include("url" => url, "events" => ["message"])
    expect(webhook).to include("hmac" => { "key" => "hmac-secret" }, "retries" => { "attempts" => 2 })
  end

  it "returns unchanged without PUT when the desired webhook already exists" do
    unchanged = {
      "name" => "team/a b",
      "config" => {
        "webhooks" => [
          { "url" => url, "events" => ["message"], "hmac" => { "key" => "same" } }
        ]
      }
    }
    transport.instance_variable_set(:@responses, [unchanged])

    expect(resource.configure(url:, events: "message", hmac_secret: "same")).to eq(:unchanged)
    expect(transport.requests.none? { |request| request.method == :put }).to be(true)
  end

  it "requires the session response to include config" do
    transport.instance_variable_set(:@responses, [{ "name" => "team/a b" }])

    expect { resource.configure(url:, events: []) }.to raise_error(Waha::ApiError, /missing config/)
  end
end
