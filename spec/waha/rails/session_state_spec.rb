# frozen_string_literal: true

require "waha/rails"

RSpec.describe Waha::Rails::SessionState do
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }

  before do
    allow(Rails).to receive(:cache).and_return(cache)
    Waha.configure do |config|
      config.base_url = "http://waha.test"
      config.session = "default"
    end
  end

  after { Waha.reset_configuration! }

  it "is inactive when WAHA is not configured" do
    Waha.configure { |config| config.base_url = nil }

    expect(described_class.active?).to be(false)
  end

  it "memoizes readiness per session" do
    client = instance_double(Waha::Client)
    ready = instance_double(Waha::Resources::Sessions, ready?: true)
    allow(Waha).to receive(:client).with(session: "default").and_return(client)
    allow(client).to receive(:sessions).and_return(ready)

    2.times { described_class.active? }

    expect(Waha).to have_received(:client).once
  end

  it "builds a cache key per session name" do
    expect(described_class.cache_key("client_1")).to eq("waha:session_active:client_1")
  end
end
