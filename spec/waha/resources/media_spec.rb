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

  it "rebases loopback IP origins to the configured WAHA base URL" do
    resource.download(url: "http://127.0.0.1:3000/api/files/a.oga")

    expect(transport.requests.last.path).to eq("http://waha.test:3000/api/files/a.oga")
  end

  it "accepts a media URL served by the configured WAHA host" do
    url = "http://waha.test:3000/api/files/default/file.bin?x=1"
    resource.download(url:)

    expect(transport.requests.last.path).to eq(url)
  end

  it "rejects media URLs from hosts other than the configured WAHA server" do
    expect { resource.download(url: "https://cdn.test/file.bin?x=1") }
      .to raise_error(Waha::ValidationError, /media URL host is not the WAHA server/)
  end

  it "rejects invalid or relative media URLs" do
    expect { resource.download(url: "/api/files/a") }.to raise_error(Waha::ValidationError)
    expect { resource.download(url: "http://") }.to raise_error(Waha::ValidationError)
  end
end
