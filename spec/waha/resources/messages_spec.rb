# frozen_string_literal: true

RSpec.describe Waha::Resources::Messages do
  let(:transport) { SpecTransport::Fake.new }
  let(:resource) { described_class.new(transport:, session: "default") }

  it "sends text with optional generated id and reply override session" do
    resource.send_text(
      chat_id: "15551234567@c.us",
      text: "Hello",
      id: "3EB0123456789012345678",
      reply_to: "false_x",
      session: "work"
    )

    request = transport.requests.last
    expect(request.method).to eq(:post)
    expect(request.path).to eq("/api/sendText")
  end

  it "posts the complete sendText body" do
    resource.send_text(chat_id: "15551234567@c.us", text: "Hello", id: "3EB0123456789012345678", session: "work")

    expect(transport.requests.last.body).to eq(
      session: "work",
      chatId: "15551234567@c.us",
      text: "Hello",
      id: "3EB0123456789012345678"
    )
  end

  it "builds remote file payloads" do
    resource.send_image(chat_id: "c@c.us", file: "https://cdn.test/pic.jpg", mimetype: "image/jpeg", caption: "cap")

    file = transport.requests.last.body[:file]
    expect(file).to eq(url: "https://cdn.test/pic.jpg", mimetype: "image/jpeg")
  end

  it "omits mimetype for remote files when none is supplied" do
    resource.send_image(chat_id: "c@c.us", file: "https://cdn.test/pic.jpg", caption: "cap")

    file = transport.requests.last.body[:file]
    expect(file).to eq(url: "https://cdn.test/pic.jpg")
  end

  it "accepts both 200 and 201 send responses" do
    resource.send_text(chat_id: "c@c.us", text: "Hi")

    expect(transport.requests.last.expected_status).to eq([200, 201])
  end

  it "infers the mimetype from a data URL when none is supplied" do
    resource.send_image(chat_id: "c@c.us", file: "data:image/png;base64,AAAA")

    expect(transport.requests.last.body[:file]).to eq(data: "AAAA", mimetype: "image/png")
  end

  it "requires an explicit mimetype for data URLs that omit one" do
    expect do
      resource.send_file(chat_id: "c@c.us", file: "data:;base64,AAAA")
    end.to raise_error(Waha::ValidationError, /mimetype is required/)
  end

  it "builds data file payloads and strips data URL prefixes" do
    resource.send_voice(chat_id: "c@c.us", file: "data:audio/ogg;base64,AAAA", mimetype: "audio/ogg", convert: true)

    request = transport.requests.last
    expect(request.body[:file]).to eq(data: "AAAA", mimetype: "audio/ogg")
    expect(request.body[:convert]).to be(true)
  end

  it "rejects invalid file sources without leaking payloads" do
    expect do
      resource.send_file(chat_id: "c@c.us", file: "not-a-url", mimetype: "text/plain")
    end.to raise_error(Waha::ValidationError, /http\(s\) URL or data URL/)
  end

  it "edits a message through the encoded chat path" do
    resource.edit(chat_id: "1555/space @c.us", message_id: "true_1555/space @c.us_3EB0123456789012345678", text: "Done")

    request = transport.requests.last
    expect(request.method).to eq(:put)
    expect(request.path).to include("/chats/1555%2Fspace%20%40c.us/messages/")
  end

  it "finds and lists messages through encoded chat paths" do
    resource.find(chat_id: "15551234567@c.us", message_id: "true_15551234567@c.us_3EB0123456789012345678")
    resource.list(chat_id: "15551234567@c.us", limit: 50, download_media: false)

    find_request = transport.requests[-2]
    list_request = transport.requests.last
    expect(find_request.method).to eq(:get)
    expect(list_request.query).to include(limit: 50, "downloadMedia" => false)
  end

  it "marks chat as seen with optional message ids" do
    resource.send_seen(chat_id: "15551234567@c.us", message_ids: ["abc"])

    expect(transport.requests.last.body[:messageIds]).to eq(["abc"])
  end

  it "posts typing controls and fetches a new message id" do
    resource.start_typing(chat_id: "c@c.us")
    resource.stop_typing(chat_id: "c@c.us")
    resource.new_message_id(session: "work/session")

    start_request = transport.requests[-3]
    expect(transport.requests[-2].path).to eq("/api/stopTyping")
    expect(start_request.body).to eq(session: "default", chatId: "c@c.us")
    expect(transport.requests.last.path).to eq("/api/work%2Fsession/new-message-id")
  end
end
