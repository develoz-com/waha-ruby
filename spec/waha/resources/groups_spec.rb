# frozen_string_literal: true

RSpec.describe Waha::Resources::Groups do
  let(:transport) { SpecTransport::Fake.new }
  let(:resource) { described_class.new(transport:, session: "default") }

  it "lists groups for the default session" do
    resource.list

    request = transport.requests.last
    expect(request.method).to eq(:get)
    expect(request.path).to eq("/api/default/groups")
    expect(request.query).to eq({})
  end

  it "lists groups with query keywords and an override session" do
    resource.list(limit: 5, session: "work/session")

    request = transport.requests.last
    expect(request.path).to eq("/api/work%2Fsession/groups")
    expect(request.query).to eq(limit: 5)
  end

  it "fetches a single group by encoded id" do
    resource.get(group_id: "120363@g.us")

    request = transport.requests.last
    expect(request.path).to eq("/api/default/groups/120363%40g.us")
  end
end
