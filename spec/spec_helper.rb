# frozen_string_literal: true

require "rspec"
require "webmock/rspec"
require "waha"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
end

module SpecTransport
  Request = Data.define(
    :http_method, :path, :operation, :expected_status,
    :body, :query, :headers, :timeout, :response
  ) do
    alias_method :method, :http_method
  end

  class Fake
    def initialize(responses = [])
      @responses = responses
      @requests = []
    end

    attr_reader :requests

    def escape_path_segment(value)
      URI.encode_www_form_component(value.to_s).gsub("+", "%20")
    end

    def request(**attributes)
      normalized = {
        body: nil,
        query: nil,
        headers: nil,
        timeout: nil,
        response: :json
      }.merge(attributes)
      @requests << Request.new(http_method: normalized.delete(:method), **normalized)
      next_response = @responses.empty? ? nil : @responses.shift
      raise next_response if next_response.is_a?(Exception)

      next_response
    end
  end
end
