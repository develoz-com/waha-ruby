# frozen_string_literal: true

require "stringio"
require "waha/rails"

RSpec.describe Waha::Rails::ControllerConcern do
  subject(:controller) do
    Class.new do
      include Waha::Rails::ControllerConcern

      attr_accessor :request

      private

      def waha_webhook_secret
        "webhook-secret"
      end
    end.new
  end

  let(:body) { StringIO.new("{\"event\":\"message\"}") }
  let(:headers) do
    {
      "X-Webhook-Hmac" => "signed-digest",
      "X-Webhook-Hmac-Algorithm" => "sha512"
    }
  end
  let(:request) { Struct.new(:body, :headers).new(body, headers) }

  before do
    controller.request = request
  end

  describe "#verify_waha_webhook!" do
    it "verifies the exact raw request body and rewinds it" do
      allow(Waha::Webhook).to receive(:verify!).and_return(true)

      result = controller.send(:verify_waha_webhook!)

      expect(result).to be(true)
      expect(body.pos).to be_zero
      expect(Waha::Webhook).to have_received(:verify!).with(
        body: "{\"event\":\"message\"}",
        signature: "signed-digest",
        algorithm: "sha512",
        secret: "webhook-secret"
      )
    end

    it "rewinds the request body when verification fails" do
      error = Waha::VerificationError.new(
        operation: "verify_webhook",
        details: "Invalid WAHA webhook signature"
      )
      allow(Waha::Webhook).to receive(:verify!).and_raise(error)

      expect { controller.send(:verify_waha_webhook!) }
        .to raise_error(Waha::VerificationError, /Invalid WAHA webhook signature/)
      expect(body.pos).to be_zero
    end
  end
end
