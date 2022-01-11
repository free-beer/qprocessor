# QProcessor

A simple library that wraps the processing of elements pulled from a queue. Initial
implementation will work with Beanstalkd, though I might expand it to cover other
types of queue later. The idea behind this gem is to allow for the easy creation
of an application as a service, where the services job is to pull items from a
queue and process them. The library code is intended to wrap the parts of the code
that would be common and repeated if you made individual service applications.

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

TODO: Write usage instructions here

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/free-beer/qprocessor.
