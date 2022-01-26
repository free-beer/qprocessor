require "spec_helper"

describe QProcessor::Processor do
  let(:fake_processor) {
    object = OpenStruct.new
    def object.process(message)
    end
    object
  }

  let(:message) {
    object = OpenStruct.new()
    def object.dispose
    end

    def object.release
    end
    object
  }

  describe "#handle()" do
    it "calls the #process() method of the processor class" do
      expect(fake_processor).to receive(:process).with(message)
      expect(OpenStruct).to receive(:new).and_return(fake_processor)
      processor = QProcessor::Processor.new(OpenStruct)
      processor.handle(message)
    end

    describe "when processing is successful" do
      it "calls the #dispose() method on the message" do
        allow(fake_processor).to receive(:process)
        allow(OpenStruct).to receive(:new).and_return(fake_processor)
        expect(message).to receive(:dispose)
        processor = QProcessor::Processor.new(OpenStruct)
        processor.handle(message)
      end
    end

    describe "when processing fails" do
      it "calls the #release() method on the message" do
        allow(fake_processor).to receive(:process).and_raise("Fake exception.")
        allow(OpenStruct).to receive(:new).and_return(fake_processor)
        expect(message).to receive(:release)
        processor = QProcessor::Processor.new(OpenStruct)
        expect {
          processor.handle(message)
        }.to raise_error(RuntimeError)
      end
    end
  end
end
