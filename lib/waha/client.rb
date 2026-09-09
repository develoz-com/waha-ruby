# frozen_string_literal: true

module Waha
  class Client
    RESOURCES = {
      sessions: Resources::Sessions,
      messages: Resources::Messages,
      chats: Resources::Chats,
      contacts: Resources::Contacts,
      presence: Resources::Presence,
      webhooks: Resources::Webhooks,
      media: Resources::Media
    }.freeze

    def initialize(base_url:, api_key:, session: nil, timeout: 30, transport: nil)
      @base_url = base_url
      @session = session
      @transport = transport || Transport::Faraday.new(base_url:, api_key:, timeout:)
      @resources = {}
    end

    RESOURCES.each do |name, resource_class|
      define_method(name) do
        @resources[name] ||= build_resource(name, resource_class)
      end
    end

    private

    def build_resource(name, resource_class)
      return resource_class.new(transport: @transport, base_url: @base_url) if name == :media
      return resource_class.new(transport: @transport, session: @session, sessions:) if name == :webhooks

      resource_class.new(transport: @transport, session: @session)
    end
  end
end
