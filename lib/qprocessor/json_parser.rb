require "json"

module QProcessor
  # A parser class that treats the job contents as YAML.
  class JSONParser
    def initialize(settings={})
      @settings = {}.merge(settings)
    end

    def parse(job)
      JSON.parse(job.body)
    end
  end
end
