# frozen_string_literal: true

RSpec.describe Waha::Transport::Faraday do
  subject(:transport) { described_class.new(base_url: "http://waha.test", api_key: "secret-key", timeout: 30) }

  it "joins base URL and path, sends JSON defaults, and parses JSON responses" do
    stub_request(:get, "http://waha.test/api/sessions/")
      .with(headers: { "X-Api-Key" => "secret-key", "User-Agent" => "waha-ruby/#{Waha::VERSION}" })
      .to_return(
        status: 200,
        body: [{ "name" => "default" }].to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = transport.request(method: :get, path: "/api/sessions/", operation: "list_sessions", expected_status: 200)

    expect(result).to eq([{ "name" => "default" }])
  end

  it "serializes request bodies and query params" do
    stub_request(:post, "http://waha.test/api/sendText?dry=1")
      .with(body: { session: "default", chatId: "c@c.us", text: "Hi" }.to_json)
      .to_return(status: 201, body: { "id" => "x" }.to_json)

    result = transport.request(
      method: :post,
      path: "/api/sendText",
      operation: "send_text",
      expected_status: 201,
      body: { session: "default", chatId: "c@c.us", text: "Hi" },
      query: { dry: "1" }
    )

    expect(result).to eq("id" => "x")
  end

  it "returns binary bodies as-is" do
    stub_request(:get, "http://waha.test/file").to_return(status: 200, body: "BIN\x89")

    binary = transport.request(
      method: :get,
      path: "/file",
      operation: "download_media",
      expected_status: 200,
      response: :binary
    )

    expect(binary).to eq("BIN\x89")
  end

  it "returns nil for successful empty JSON responses" do
    stub_request(:post, "http://waha.test/api/sessions/default/start").to_return(status: 200, body: "")

    empty = transport.request(
      method: :post,
      path: "/api/sessions/default/start",
      operation: "start_session",
      expected_status: 200
    )

    expect(empty).to be_nil
  end

  it "raises ApiError for non-expected statuses without leaking response data" do
    stub_request(:get, "http://waha.test/api/fail")
      .to_return(status: 500, body: { "error" => "private secret-key message" }.to_json)

    expect do
      transport.request(method: :get, path: "/api/fail", operation: "send_text", expected_status: 200)
    end.to raise_error(Waha::ApiError, /\[REDACTED\]/) { |error|
      expect(error.status).to eq(500)
      expect(error.message).not_to include("private secret-key message", "secret-key")
    }
  end

  it "marks empty error payloads explicitly" do
    stub_request(:get, "http://waha.test/api/fail-empty").to_return(status: 404, body: "")

    expect do
      transport.request(method: :get, path: "/api/fail-empty", operation: "get_session", expected_status: 200)
    end.to raise_error(Waha::ApiError, /empty provider error response/)
  end

  it "raises TransportError for malformed successful JSON" do
    stub_request(:get, "http://waha.test/api/bad-json").to_return(status: 200, body: "{bad")

    expect do
      transport.request(method: :get, path: "/api/bad-json", operation: "list_sessions", expected_status: 200)
    end.to raise_error(Waha::TransportError, /invalid JSON response/)
  end

  it "raises TransportError for network failures without leaking credentials" do
    stub_request(:get, "http://waha.test/api/down").to_raise(SocketError.new("name or service not known"))

    expect do
      transport.request(method: :get, path: "/api/down", operation: "get_session", expected_status: 200)
    end.to raise_error(Waha::TransportError, /transport failure/) { |error|
      expect(error.message).not_to include("secret-key")
    }
  end

  it "rejects invalid request paths deterministically" do
    expect do
      transport.request(method: :get, path: "///", operation: "request", expected_status: 200)
    end.to raise_error(Waha::ValidationError)
  end

  it "rejects unsupported response modes" do
    stub_request(:get, "http://waha.test/api/raw").to_return(status: 200, body: "plain text")

    expect do
      transport.request(method: :get, path: "/api/raw", operation: "download", expected_status: 200, response: :text)
    end.to raise_error(Waha::ValidationError)
  end
end
