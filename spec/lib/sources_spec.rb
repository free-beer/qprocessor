require "spec_helper"

describe QProcessor::Sources do
  describe "#manufacture!()" do
    describe "when the BEANSTALK_URL environment variable is set" do
      after do
        ENV.delete("BEANSTALK_URL")
      end

      it "returns a QProcessor::BeanstalkSource instance" do
        ENV["BEANSTALK_URL"] = "beanstalk://localhost:11300/queue_name"
        source = QProcessor::Sources.manufacture!
        expect(source.class.name).to eq(QProcessor::BeanstalkSource.name)
      end
    end

    describe "when the BEANSTALK_URL environment variable is set" do
      after do
        ENV.delete("SQS_QUEUE_NAME")
      end

      it "returns a QProcessor::SQSSource instance" do
        ENV["SQS_QUEUE_NAME"] = "sqs_queue_name"
        source = QProcessor::Sources.manufacture!
        expect(source.class.name).to eq(QProcessor::SQSSource.name)
      end
    end

    describe "when no valid environment variable is set" do
      it "raises an exception" do
        expect {
          source = QProcessor::Sources.manufacture!
        }.to raise_error(RuntimeError, "Unable to determine source queue type from environment settings.")
      end
    end
  end
end
