require "spec_helper"

describe QProcessor::BeanstalkSource do
  after do
    ENV.delete("BEANSTALK_URL")
  end

  describe "#get()" do
    let(:fake_beanstalk) {
      OpenStruct.new(tubes: {"queue_name" => fake_tube})
    }

    let(:fake_tube) {
      OpenStruct.new(reserve: {})
    }

    it "returns instances of the QProcessor::BeanstalkMessage class" do
      ENV["BEANSTALK_URL"] = "beanstalk://localhost:11300/queue_name"
      allow(Beaneater).to receive(:new).and_return(fake_beanstalk)
      source = QProcessor::BeanstalkSource.new
      message = source.get
      expect(message.class).to eq(QProcessor::BeanstalkMessage)
    end
  end
end
