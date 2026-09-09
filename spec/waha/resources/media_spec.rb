# frozen_string_literal: true

RSpec.describe Waha::Resources::Media do
  let(:transport) { SpecTransport::Fake.new(["binary"]) }
  let(:resource) { described_class.new(transport:, base_url: "http://waha.test:3000") }

  it "rebases localhost origins and downloads binary content" do
    result = resource.download(url: "http://localhost:3000/api/files/default/message.oga?download=1")

    request = transport.requests.last
    expect(result).to eq("binary")
    expect(request.path).to eq("http://waha.test:3000/api/files/default/message.oga?download=1")
    expect(request.response).to eq(:binary)
  end

  it "keeps a non-local media URL unchanged" do
    url = "https://cdn.test/file.bin?x=1"
    resource.download(url:)

    expect(transport.requests.last.path).to eq(url)
  end

  it "rejects invalid or relative media URLs" do
    expect { resource.download(url: "/api/files/a") }.to raise_error(Waha::ValidationError)
    expect { resource.download(url: "http://") }.to raise_error(Waha::ValidationError)
  end
end
