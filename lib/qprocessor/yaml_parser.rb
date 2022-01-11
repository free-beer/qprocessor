require "yaml"

module QProcessor
  # A parser class that treats the job contents as YAML.
  class YAMLParser
    def initialize(settings={})
      @settings = {}.merge(settings)
    end

    def parse(job)
      YAML.load(job.body)
    end
  end
end
