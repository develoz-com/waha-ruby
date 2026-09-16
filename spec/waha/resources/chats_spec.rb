# frozen_string_literal: true

RSpec.describe Waha::Resources::Chats do
  let(:transport) { SpecTransport::Fake.new }
  let(:resource) { described_class.new(transport:, session: "team/a b") }

  it "lists chats for the session with compact query keywords" do
    resource.list(limit: 10, session: "work/session")

    request = transport.requests.last
    expect(request.method).to eq(:get)
    expect(request.path).to eq("/api/work%2Fsession/chats")
    expect(request.query).to eq(limit: 10)
  end

  it "gets overview with compact query keywords" do
    resource.overview(limit: 5, ids: ["a@c.us"])

    request = transport.requests.last
    expect(request.path).to eq("/api/team%2Fa%20b/chats/overview")
    expect(request.query).to eq(limit: 5, ids: ["a@c.us"])
  end

  it "gets chat messages with compact query keywords" do
    resource.messages(chat_id: "a@c.us", limit: 50, download_media: true)

    request = transport.requests.last
    expect(request.path).to eq("/api/team%2Fa%20b/chats/a%40c.us/messages")
    expect(request.query).to eq(limit: 50, "downloadMedia" => true)
  end

  it "translates the last message query keyword" do
    resource.messages(chat_id: "a@c.us", last_message_id: "msg-1", limit: nil)

    expect(transport.requests.last.query).to eq("lastMessageId" => "msg-1")
  end
end
