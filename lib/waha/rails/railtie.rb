# frozen_string_literal: true

require "active_support/ordered_options"

module Waha
  module Rails
    class Railtie < ::Rails::Railtie
      config.waha = ActiveSupport::OrderedOptions.new
    end
  end
end
