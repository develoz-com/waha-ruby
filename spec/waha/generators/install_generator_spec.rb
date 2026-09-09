# frozen_string_literal: true

require "fileutils"
require "tmpdir"
require "waha/rails"
require "generators/waha/install/install_generator"

RSpec.describe Waha::Generators::InstallGenerator do
  let(:initializer) do
    <<~RUBY
      # frozen_string_literal: true

      # Keep WAHA credentials in the application environment. The factory creates a
      # fresh client for each caller, so session-specific state is never shared.
      Rails.application.config.waha.client_factory = lambda do |session: ENV.fetch("WAHA_SESSION")|
        Waha::Client.new(
          base_url: ENV.fetch("WAHA_BASE_URL"),
          api_key: ENV.fetch("WAHA_API_KEY"),
          session: session
        )
      end

      # Used by Waha::Rails::ControllerConcern#verify_waha_webhook!.
      Rails.application.config.waha.webhook_secret = -> { ENV.fetch("WAHA_WEBHOOK_HMAC_KEY") }
    RUBY
  end

  it "creates the documented initializer exactly and idempotently" do
    Dir.mktmpdir do |destination|
      2.times { described_class.start([], destination_root: destination) }

      path = File.join(destination, "config/initializers/waha.rb")
      expect(File.read(path)).to eq(initializer)
      expect(Dir.glob(File.join(destination, "config/initializers/waha.rb*"))).to contain_exactly(path)
    end
  end
end
