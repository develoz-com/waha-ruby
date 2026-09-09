# frozen_string_literal: true

RSpec.describe Waha::Resources::Contacts do
  let(:transport) { SpecTransport::Fake.new }
  let(:resource) { described_class.new(transport:, session: "default") }

  it "lists contacts using the official session query parameter" do
    resource.list(limit: 10)

    request = transport.requests.last
    expect(request.path).to eq("/api/contacts/all")
    expect(request.query).to eq(session: "default", limit: 10)
  end

  it "gets a contact and checks phone existence with official query parameters" do
    resource.get(contact_id: "15551234567@c.us")
    resource.check_exists(phone: "15551234567", session: "work")

    get_request = transport.requests[-2]
    check_request = transport.requests.last
    expect(get_request.query).to eq(session: "default", contactId: "15551234567@c.us")
    expect(check_request.query).to eq(session: "work", phone: "15551234567")
  end
end
