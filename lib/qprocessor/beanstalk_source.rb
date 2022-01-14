require "beaneater"

module QProcessor
  class BeanstalkSource
    # A constant for a regular expression to match Beanstalk URLs
    BEANSTALK_URL_PATTERN = /^beanstalk:\/\/([^:\/]+)[:]?([\d]*)[\/]?(.*)$/

    # The default Beanstalk tube name.
    DEFAULT_TUBE_NAME = "default"

    def initialize
      @name = "Beanstalk Source"
    end
    attr_reader :name

    # This method blocks until a job is available, at which points it is
    # returned.
    def get
      job = connection.reserve
      job = OpenStruct.new(body: job.body, id: job.id)
      yield job if block_given?
      job
    end

  private

    def beanstalk_url
      @beanstalk_url ||= ENV["BEANSTALK_URL"]
    end

    def connection
      if !@connection
        match = BEANSTALK_URL_PATTERN.match(beanstalk_url)
        raise QProcessor::Error("Invalid Beanstalk queue URL '#{beanstalk_url}' specified.") if !match
        beanstalk   = Beaneater.new("#{match[1]}#{match[2] == "" ? "" : ":#{match[2]}"}")
        @connection = beanstalk.tubes[match[3] != "" ? match[3] : DEFAULT_TUBE_NAME]
      end
      @connection
    end

    def tube_name
      ENV["BEANSTALK_TUBE_NAME"] || DEFAULT_TUBE_NAME
    end
  end
end
