require "qprocessor/message"

module QProcessor
  class SQSMessage < Message
    def initialize(source, client, queue_url)
      super(source)
      @client    = client
      @queue_url = queue_url
    end

    # Deletes a message from the source queue.
    def dispose
      @client.delete_message(queue_url: @queue_url, receipt_handle: source.receipt_handle)
    end

    # Retrieves the message identifier.
    def id
      source.message_id
    end
  end
end
