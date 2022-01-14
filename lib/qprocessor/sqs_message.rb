require "qprocessor/message"

module QProcessor
  class SQSMessage < Message
    def initialize(source, client, queue_url)
      super(source)
      @client    = client
      @queue_url = queue_url
    end

    # Retrieves the message identifier.
    def id
      source.message_id
    end

    # Returns a message back to the queue from which it was extracted. Note
    # that this can fail in the case of network failure or similar occurrence.
    def release
      @client.send_message(message_body: body, queue_url: @queue_url)
    end
  end
end
