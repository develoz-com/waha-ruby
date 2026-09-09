# frozen_string_literal: true

RSpec.describe Waha::Resources::Sessions do
  let(:transport) { SpecTransport::Fake.new }
  let(:resource) { described_class.new(transport:, session: "default") }

  it "lists sessions with the official trailing slash path" do
    resource.list

    expect(transport.requests.last.path).to eq("/api/sessions/")
    expect(transport.requests.last.method).to eq(:get)
  end

  it "gets a session with an encoded session segment" do
    resource.get(session: "team/a b")

    expect(transport.requests.last.path).to eq("/api/sessions/team%2Fa%20b")
  end

  it "uses the client default session when no override is supplied" do
    resource.get

    expect(transport.requests.last.path).to eq("/api/sessions/default")
  end

  it "raises a validation error when no session is available" do
    resource = described_class.new(transport:, session: nil)

    expect { resource.get }.to raise_error(Waha::ValidationError, /session is required/)
  end

  it "creates and controls sessions through the upstream endpoints" do
    resource.create(name: "team/a b", start: true)
    resource.restart(session: "team/a b")
    resource.destroy(session: "team/a b")

    create_request, restart_request, delete_request = transport.requests.last(3)
    expect(create_request.body).to eq(name: "team/a b", start: true)
    expect(restart_request.path).to eq("/api/sessions/team%2Fa%20b/restart")
    expect(delete_request.method).to eq(:delete)
  end

  it "requests the QR PNG by default and supports raw format" do
    resource.qr
    resource.qr(format: "raw", session: "team/a b")

    default_request, raw_request = transport.requests.last(2)
    expect(default_request.response).to eq(:binary)
    expect(raw_request.response).to eq(:json)
    expect(raw_request.query).to eq(format: "raw")
  end

  it "posts request-code payload with the official phoneNumber field" do
    resource.request_code(phone_number: "15551234567", method: "sms")

    expect(transport.requests.last.path).to eq("/api/default/auth/request-code")
    expect(transport.requests.last.body).to eq(phoneNumber: "15551234567", method: "sms")
  end
end
