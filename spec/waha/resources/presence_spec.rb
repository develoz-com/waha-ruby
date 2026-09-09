# frozen_string_literal: true

RSpec.describe Waha::Resources::Presence do
  let(:transport) { SpecTransport::Fake.new }
  let(:resource) { described_class.new(transport:, session: "default") }

  it "subscribes to chat presence through the upstream subscribe endpoint" do
    resource.subscribe(chat_id: "chat@c.us")

    request = transport.requests.last
    expect(request.method).to eq(:post)
    expect(request.path).to eq("/api/default/presence/chat%40c.us/subscribe")
    expect(request.expected_status).to eq([200, 201])
  end

  it "can list and fetch presence from upstream-supported reads" do
    resource.list
    resource.get(chat_id: "chat@c.us", session: "work/session")

    expect(transport.requests[-2].path).to eq("/api/default/presence")
    expect(transport.requests.last.path).to eq("/api/work%2Fsession/presence/chat%40c.us")
  end
end
