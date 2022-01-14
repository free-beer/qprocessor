require "aws-sdk-sqs"
require "aws-sdk-sts"

module QProcessor
  class SQSSource
    # A constant for the maximum wait for message timeout to be used by the
    # source.
    MAX_MESSAGE_WAIT = 3

    def initialize
      @name = "SQS Source"
    end
    attr_reader :name

    # This method blocks until a job is available, at which points it is
    # returned.
    def get
      entry  = nil
      client = sqs_client
      url    = sqs_queue_url
      while entry.nil?
        result = client.receive_message(max_number_of_messages: 1,
                                        queue_url:              url,
                                        wait_time_seconds:      MAX_MESSAGE_WAIT)
        entry = SQSMessage.new(result.messages[0], client, url) if result.messages.empty?
      end
      yield entry if block_given?
      entry
    end

  private

    # Attempts to fetch the AWS access key from environment variables, raising
    # an exception if not found.
    def aws_access_key
      @aws_access_key ||= ENV["AWS_ACCESS_KEY"]
      raise "The AWS_ACCESS_KEY environment variable has not been set." if @aws_access_key.nil?
      @aws_access_key
    end

    # Creates a Aws::Credentials instance from AWS settings read from the
    # environment. An exception will be raised if any of these settings is
    # not present.
    def aws_credentials
      Aws::Credentials.new(aws_access_key, aws_secret_key)
    end

    # Attempts to fetch the AWS region from environment variables, raising an
    # exception if not found.
    def aws_region
      @aws_region ||= ENV["AWS_REGION"]
      raise "The AWS_REGION environment variable has not been set." if @aws_region.nil?
      @aws_region
    end

    # Attempts to fetch the AWS secret key from environment variables, raising
    # an exception if not found.
    def aws_secret_key
      @aws_secret_key ||= ENV["AWS_SECRET_KEY"]
      raise "The AWS_SECRET_KEY environment variable has not been set." if @aws_secret_key.nil?
      @aws_secret_key
    end

    def connection
      if !@connection
        url = beanstalk_url
        raise "No BEANSTALK_URL environment variable set." if url.nil?
        @connection ||= Beaneater.new(url)
      end
      @connection
    end

    # Fetches a Aws::SQS::Client instance using AWS credentials and region
    # details that are read from environment settings. If any of these settings
    # are missing an exception will be raised.
    def sqs_client
      Aws::SQS::Client.new(credentials: aws_credentials, region: aws_region)
    end

    # Generates an URL for use with a specific AWS SQS queue.
    def sqs_queue_url(queue_name)
      if !@sqs_queue_url
        client = Aws::STS::Client.new(credentials: aws_credentials, region: aws_region)
        @sqs_queue_url = "https://sqs.#{aws_region}.amazonaws.com/#{client.get_caller_identity.account}/#{queue_name}"
      end
      @sqs_queue_url
    end
  end
end
