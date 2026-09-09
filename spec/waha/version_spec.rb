# frozen_string_literal: true

require "open3"
require "rbconfig"

RSpec.describe Waha::VERSION do
  it "loads without Rails constants or dependencies" do
    script = <<~RUBY
      require "waha"
      abort "Rails constant loaded" if defined?(Rails)
      abort "Rails dependency loaded" if $LOADED_FEATURES.any? { |feature| feature.include?("/rails/") || feature.include?("railtie") }
    RUBY

    _output, status = Open3.capture2e(
      RbConfig.ruby,
      "-I#{File.expand_path('../../../lib', __dir__)}",
      "-e",
      script
    )

    expect(status).to be_success
  end
end
