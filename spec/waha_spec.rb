# frozen_string_literal: true

RSpec.describe Waha do
  around do |example|
    original = described_class.configuration
    example.run
  ensure
    described_class.instance_variable_set(:@configuration, original)
  end

  it "exposes a configurable default client factory" do
    described_class.configure do |config|
      config.base_url = "http://waha.test"
      config.api_key = "secret"
      config.session = "default"
      config.timeout = 5
    end

    client = described_class.client(session: "other")

    expect(described_class).to be_configured
    expect(client).to be_a(Waha::Client)
    expect(client.session).to eq("other")
  end

  it "reports unconfigured when the base URL is blank" do
    described_class.configure { |config| config.base_url = "  " }

    expect(described_class).not_to be_configured
  end

  it "resets configuration to environment defaults" do
    described_class.configure { |config| config.base_url = "http://waha.test" }

    described_class.reset_configuration!

    expect(described_class.configuration.session).to eq(Waha::DEFAULT_SESSION)
  end

  describe "chat id helpers" do
    it "accepts contact, group, and lid chat ids" do
      expect(described_class.valid_chat_id?("1555123@c.us")).to be(true)
      expect(described_class.valid_chat_id?("120363@g.us")).to be(true)
      expect(described_class.valid_chat_id?("155980377682063@lid")).to be(true)
    end

    it "rejects blank and malformed ids" do
      expect(described_class.valid_chat_id?(nil)).to be(false)
      expect(described_class.valid_chat_id?("")).to be(false)
    end

    it "rejects ids with unknown suffixes" do
      expect(described_class.valid_chat_id?("invalid-id")).to be(false)
      expect(described_class.valid_chat_id?("120363@s.whatsapp.net")).to be(false)
    end

    it "appends the group suffix only when missing" do
      expect(described_class.group_chat_id("120363")).to eq("120363@g.us")
      expect(described_class.group_chat_id("120363@g.us")).to eq("120363@g.us")
    end
  end
end
