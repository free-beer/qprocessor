require "spec_helper"

describe QProcessor::SQSMessage do
  let(:fake_client) {
    object = OpenStruct.new()
    def object.delete_message(params={})
    end
    object
  }

  let(:fake_source) {
    OpenStruct.new(message_id: {}, receipt_handle: "")
  }

  describe "#dispose()" do
    it "invokes delete_message on the underlying message client" do
      expect(fake_client).to receive(:delete_message).with({queue_url: "sqs://fake/queue/url", receipt_handle: ""})
      message = QProcessor::SQSMessage.new(fake_source, fake_client, "sqs://fake/queue/url")
      message.dispose
    end
  end

  describe "#id()" do
    it "invokes id on the underlying source" do
      expect(fake_source).to receive(:message_id)
      message = QProcessor::SQSMessage.new(fake_source, fake_client, "sqs://fake/queue/url")
      message.id
    end
  end
end
