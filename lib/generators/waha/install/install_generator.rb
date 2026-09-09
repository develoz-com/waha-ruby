# frozen_string_literal: true

require "rails/generators"

module Waha
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        copy_file "waha.rb", "config/initializers/waha.rb"
      end
    end
  end
end
