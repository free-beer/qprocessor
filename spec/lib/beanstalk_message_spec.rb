require "spec_helper"

describe QProcessor::BeanstalkMessage do
  let(:fake_source) {
    OpenStruct.new(delete: {}, id: {}, release: {})
  }

  describe "#dispose()" do
    it "invokes delete on the underlying source" do
      expect(fake_source).to receive(:delete)
      message = QProcessor::BeanstalkMessage.new(fake_source)
      message.dispose
    end
  end

  describe "#id()" do
    it "invokes id on the underlying source" do
      expect(fake_source).to receive(:id)
      message = QProcessor::BeanstalkMessage.new(fake_source)
      message.id
    end
  end

  describe "#release()" do
    it "invokes release on the underlying source" do
      expect(fake_source).to receive(:release)
      message = QProcessor::BeanstalkMessage.new(fake_source)
      message.release
    end
  end
end
