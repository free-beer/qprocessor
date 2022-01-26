# QProcessor

A simple library that wraps the processing of elements pulled from a queue. The
current implementation supports the Beanstalkd and SQS queuing platforms. The
idea behind this gem is to allow for the easy creation of an 'application as a
service', where the services jobs is to pull items from a queue and process them.
The library code is intended to wrap the parts of the code that would be common
and repeated if you made individual service applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qprocessor'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install qprocessor

## Usage

There are two things that you need to do to make use of this library. The first
is to create a processor class and the second is to assemble the service
execution functionality.

### The Processor Class

The processor class is a standard Ruby class that obeys the following rules...

 1. It takes a Hash of settings for the constructor parameter. These will be
    passed down from the service when the class is instantiated.

 2. It implements a ``process()`` method that takes a single parameter. This
    parameter will be the message that was obtained from the queue. The
    message has a ``body()`` accessor method that grants access to a ``String``
    containing the message contents that are to be processed. The ``process()``
    method should conduct whatever work is needed based on the message. If
    processing of the message is complete then the ``process()`` method should
    call the ``dispose()`` method of the message parameter received as this
    informs the queuing mechanism that the message has been completely dealt
    with and should not be issued to any other requesters.

### The Service

The service should follow this general structure...

```ruby
require "qprocessor"
require "processor_class"

begin
  processor = QProcessor::Processor.new(ProcessorClass, logger: logger)
  processor.start
rescue => error
  STDERR.puts "ERROR: #{error}\n#{error.backtrace.join("\n")}"
end
```

First thing this does is require in the qprocessor library and then the processor
class (as outlined in the previous section). Next it creates an instance of the
``QProcessor::Processor`` class, passing it at least two parameters. The first
parameter is a reference to the Processor class that will be used by this
instance to handle entries read from the queue. This should be an instance of
the ``Class`` class.

The constructor accepts additional parameters in the form of a ``Hash`` of
settings. These settings will be passed down to the processor class whenever
it gets instantiated but they may also be used by the queue processor
functionality itself. For example, if the settings include  the key
``reuse_processor``, then the processor class will only be instantiated once
and then re-used for all messages. You can use this settings ``Hash`` to pass
value to the processing class that are reusable resources or that might include
configuration.

## Configuration

You need to provide the qprocessor service with details for the queue that it
will be working with. Currently supported queueing platforms include AQWS SQS
and Beanstalkd. Configuring which platform and which queue is used is done
through environment settings are outlined below...

### Beanstalkd

To use a Beanstalkd queue (tube) then you must set the ``BEANSTALK_URL``
environment setting. An example of this might be...

    ``beanstalk://host:port/tube_name``

### AWS SQS

To use the AWS SQS queuing platform you must set the ``SQS_QUEUE_NAME``
environment setting. Note that the Beanstalk configuration, if present, will
be used in preference to the SQS one - so don't configure both settings on
the same processor. The ``SQS_QUEUE_NAME`` environment variable can just be
the name of the SQS queue that will be used. The AWS SQS processor also needs
the ``AWS_ACCESS_KEY``, ``AWS_REGION`` and ``AWS_SECRET_KEY`` environment
variables set to appropriate values for use in getting access to the SQS
queue specified.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/free-beer/qprocessor.
