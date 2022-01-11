# frozen_string_literal: true

require_relative "qprocessor/json_parser"
require_relative "qprocessor/yaml_parser"
require_relative "qprocessor/processor"
require_relative "qprocessor/version"

module QProcessor
  class Error < StandardError; end
end
