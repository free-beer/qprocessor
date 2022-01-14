module QProcessor
  # This is a class representing a message or job pulled from a queue with the
  # intention of this class providing a unified interface around different
  # library classes.
  class Message
    def initialize(source)
      @source
    end

    # Retrieves the content of the message/job as a String.
    def body
      @source.body
    end

    # This method should do whatever is necessary to clean up a message/job such
    # that the underlying queuing mechanism will no longer deliver it. This is
    # a 'do nothing' implementation that can be overridden by derived classes to
    # provide for this functionality.
    def dispose
    end

    # Fetches a unique identifer for the message/job. This default implementation
    # raises an exception. Derived classes can override this to provide the
    # required functionality.
    def id
      raise "The #{self.class.name} class does not override the #id() method."
    end

    # This method should do whatever is necessary to return a message/job to the
    # underlying queuing mechanism such that it becomes available again for
    # delivery. This is a 'do nothing' implementation that can be overridden by
    # derived classes to provide for this functionality.
    def release
    end
  end
end
