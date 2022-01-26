require "spec_helper"

describe QProcessor::SQSSource do
  after do
    ENV.delete("AWS_ACCESS_KEY")
    ENV.delete("AWS_REGION")
    ENV.delete("AWS_SECRET_KEY")
    ENV.delete("SQS_QUEUE_NAME")
  end

  describe "#get()" do
    let(:fake_sqs_client) {
      object = OpenStruct.new(receive_message: {})
      def object.receive_message(params={})
        OpenStruct.new(messages: [""])
      end
      object
    }

    let(:fake_sts_client) {
      OpenStruct.new(get_caller_identity: OpenStruct.new(account: ""))
    }

    it "returns instances of the QProcessor::SQSMessage class" do
      ENV["AWS_ACCESS_KEY"] = "FakeAccessKey"
      ENV["AWS_REGION"]     = "eu-west-1"
      ENV["AWS_SECRET_KEY"] = "FakeSecretKey"
      ENV["SQS_QUEUE_NAME"] = "queue_name"
      allow(Aws::SQS::Client).to receive(:new).and_return(fake_sqs_client)
      allow(Aws::STS::Client).to receive(:new).and_return(fake_sts_client)
      source = QProcessor::SQSSource.new
      message = source.get
      expect(message.class).to eq(QProcessor::SQSMessage)
    end
  end
end
