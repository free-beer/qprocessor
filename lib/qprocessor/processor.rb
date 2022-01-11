require "beaneater"
require "logger"

module QProcessor
  # This class encapsulates a lot of the functionality around creating a queue
  # processor that pulls work from a queue and passes it to an instance of a
  # specified class for 'handling'.
  class Processor
    # A constant for a regular expression to match Beanstalk URLs
    BEANSTALK_URL_PATTERN = /^beanstalk:\/\/([^:\/]+)[:]?([\d]*)[\/]?(.*)$/

    # A constant with the name of the default job parser class.
    DEFAULT_PARSER_CLASS = "QProcessor::YAMLParser"

    # The default Beanstalk tube name.
    DEFAULT_TUBE_NAME = "default"

    # A constant containing the maximum permitted setting for the inter-error sleep interval.
    MAX_ERROR_RESTART_INTERVAL = 32

    # Constructor for the Processor class.
    #
    # @param [String] The name assigned to the processor, primarily used for logging.
    # @param [String] The URL to be used when connecting to the queue system.
    # @param [Hash] A Hash of the class names used by the processor. There are two
    #               keys recognised in this Hash - :parser and :processor. The
    #               :parser class should be the fully qualified name of the class
    #               class that can be used to parse job content. The :processor
    #               class should be the fully qualified name of the class that will
    #               process jobs.
    # @param [Hash] A Hash of additional settings that will be used by the processor.
    #               Valid keys include :logger and :reuse_processor.
    def initialize(name, url, class_names, settings={})
      @instance        = nil
      @name            = name
      @parser_class    = get_class!(class_names.fetch(:parser, DEFAULT_PARSER_CLASS))
      @processor_class = get_class!(class_names[:processor])
      @queue_url       = url
      @settings        = {}.merge(settings)
      @terminate       = false
    end
    attr_reader :class_name, :name,  :queue_url, :settings

    # Starts processing of the queue. This method will not return to the caller
    # as it will run a loop processing the queue jobs as they become available.
    def start
      queue    = connect
      interval = 0
      while !@terminate
        begin
          logger.debug("The '#{name}' queue processor is listening for jobs.")
          queue.reserve do|job|
            logger.debug "The '#{name}' queue processor received job id #{job.id}."
            handle(job)
            interval = 0
          end
        rescue => error
          logger.error "The '#{name}' queue processor caught an exception.\nType: #{error.class.name}\n"\
                       "Message: #{error}\nStack Trace:\n#{error.backtrace.join("\n")}"
          sleep(interval) if interval > 0
          interval = interval > 0 ? interval * 2 : 1
          interval = MAX_ERROR_RESTART_INTERVAL if interval > MAX_ERROR_RESTART_INTERVAL
        end
      end
    end

  private

    def beanstalk_connect
      match = BEANSTALK_URL_PATTERN.match(queue_url)
      raise QProcessor::Error("Invalid Beanstalk queue URL '#{queue_url}' specified.") if !match
      beanstalk = Beaneater.new("#{match[1]}#{match[2] == "" ? "" : ":#{match[2]}"}")
      beanstalk.tubes[match[3] != "" ? match[3] : DEFAULT_TUBE_NAME]
    end

    def connect
      if queue_url[0, 9] == "beanstalk"
        beanstalk_connect
      else
        raise QProcessor::Error.new("Unrecognised queue URL '#{queue_url}' encountered")
      end
    end

    def get_class(name)
      name.split("::").reduce(Object) {|t, e| (!t.nil? ? t.const_get(e) : nil)}
    end

    def get_class!(name)
      result = get_class(name)
      raise QProcessor::Error.new("Unable to locate the '#{class_name}' class.") if result.nil?
      result
    end

    def handle(job)
      @instance = @processor_class.new(parser: @parser_class.new(logger: logger),
                                       logger: logger) if @instance.nil?
      @instance.process(job)
      @instance = nil if !settings.fetch(:reuse_processor, true)
    end

    def logger
      settings[:logger] = Logger.new(STDOUT) if !settings.include?(:logger) || !settings[:logger]
      settings[:logger]
    end
  end
end
