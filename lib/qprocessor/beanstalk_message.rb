require "qprocessor/message"

module QProcessor
  class BeanstalkMessage < Message
    def initialize(source)
      super(source)
    end

    # Disposes of the underlying job, deleting it from Beanstalk.
    def dispose
      source.delete
    end

    # Retrieve the message identifier.
    def id
      source.id
    end

    # Releases the job back to Beanstalk.
    def release
      source.release
    end
  end
end
