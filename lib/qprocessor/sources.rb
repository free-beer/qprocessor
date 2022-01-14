require "qprocessor/beanstalk_source"
require "qprocessor/sqs_source"

module QProcessor
  module Sources
    # This method checks environment variables to see if any are set such that
    # a queue source can be generated from them. When checking environment
    # variables Beanstalk has highest priority, followed by SQS. If no matching
    # environment variables are found then an exception will be raised. For
    # Beanstalk the BEANSTALK_URL environment variable is checked for. For SQS
    # the SQS_QUEUE_NAME environment variable is check for.
    def self.manufacture!
      if !ENV["BEANSTALK_URL"].nil?
        QProcessor::BeanstalkSource.new
      elsif !ENV["SQS_QUEUE_NAME"].nil?
        QProcessor::SQSSource.new
      else
        raise "Unable to determine source queue type from environment settings."
      end
    end
  end
end