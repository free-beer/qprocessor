require "beaneater"
require "logger"
require "qprocessor/sources"

module QProcessor
  # This class encapsulates a lot of the functionality around creating a queue
  # processor that pulls work from a queue and passes it to an instance of a
  # specified class for 'handling'.
  class Processor
    # A constant containing the maximum permitted setting for the inter-error sleep interval.
    MAX_ERROR_RESTART_INTERVAL = 32

    # Constructor for the Processor class.
    #
    # @param [Class] A reference to the class that will used to process jobs.
    # @param [Hash] A Hash of additional settings that will be used by the processor.
    #               These will get passed to the processor class when it is
    #               instantiated and provides a mechansim for passing in elements
    #               such as configuration or settings.
    def initialize(processor, settings={})
      @instance        = nil
      @name            = processor.class.name
      @processor_class = processor
      @settings        = {}.merge(settings)
      @terminate       = false
    end
    attr_reader :class_name, :name,  :queue_url, :settings

    # Starts processing of the queue. This method will not return to the caller
    # as it will run a loop processing the queue jobs as they become available.
    def start
      queue    = QProcessor::Sources.manufacture!
      interval = 0
      while !@terminate
        begin
          logger.debug("The '#{name}' queue processor is listening for jobs.")
          queue.get {|message| handle(message)}
        rescue => error
          logger.error "The '#{name}' queue processor caught an exception.\nType: #{error.class.name}\n"\
                       "Message: #{error}\nStack Trace:\n#{error.backtrace.join("\n")}"
          sleep(interval) if interval > 0
          interval = interval > 0 ? interval * 2 : 1
          interval = MAX_ERROR_RESTART_INTERVAL if interval > MAX_ERROR_RESTART_INTERVAL
        end
      end
    end

    def handle(message)
      begin
        logger.debug "The '#{name}' queue processor received message id #{message.id}."
        process(message)
        message.dispose
        interval = 0
      rescue => error
        message.release
        raise
      end
    end

  private

    def process(job)
      @instance = @processor_class.new(settings) if @instance.nil?
      @instance.process(job)
      @instance = nil if !settings.fetch(:reuse_processor, true)
    end

    def logger
      if !settings.include?(:logger) || !settings[:logger]
        settings[:logger] = Logger.new(STDOUT)
        settings[:logger].level = logging_level
      end
      settings[:logger]
    end

    def logging_level
      name = ENV["LOGGING_LEVEL"].to_s
      name = "INFO" if name == "" || !Logger.const_defined?(name)
      Logger.const_get(name)
    end
  end
end
