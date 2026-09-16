# frozen_string_literal: true

require "base64"

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

  it "treats an explicit image format as binary" do
    resource.qr(format: "image", session: "team/a b")

    request = transport.requests.last
    expect(request.response).to eq(:binary)
    expect(request.query).to eq(format: "image")
  end

  it "wraps QR bytes in a PNG data URL" do
    resource = described_class.new(transport: SpecTransport::Fake.new(["\x89PNG"]), session: "default")

    expect(resource.qr_data_url).to eq("data:image/png;base64,#{Base64.strict_encode64("\x89PNG")}")
  end

  it "reports readiness only for WORKING sessions" do
    working = described_class.new(transport: SpecTransport::Fake.new([{ "status" => "WORKING" }]), session: "default")
    stopped = described_class.new(transport: SpecTransport::Fake.new([{ "status" => "STOPPED" }]), session: "default")
    failing = described_class.new(transport: SpecTransport::Fake.new([Waha::ApiError.new(operation: "get_session")]),
                                  session: "default")

    expect(working.ready?).to be(true)
    expect(stopped.ready?).to be(false)
    expect(failing.ready?).to be(false)
  end

  it "updates an existing session with a PUT" do
    resource.update(session: "team/a b", config: { "client" => {} })

    request = transport.requests.last
    expect(request.method).to eq(:put)
    expect(request.path).to eq("/api/sessions/team%2Fa%20b")
    expect(request.body).to eq(name: "team/a b", config: { "client" => {} })
  end

  it "posts request-code payload with the official phoneNumber field" do
    resource.request_code(phone_number: "15551234567", method: "sms")

    expect(transport.requests.last.path).to eq("/api/default/auth/request-code")
    expect(transport.requests.last.body).to eq(phoneNumber: "15551234567", method: "sms")
  end
end
