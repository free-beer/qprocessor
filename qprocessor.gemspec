# frozen_string_literal: true

require_relative "lib/qprocessor/version"

Gem::Specification.new do |spec|
  spec.name          = "qprocessor"
  spec.version       = QProcessor::VERSION
  spec.authors       = ["Peter Wood"]
  spec.email         = ["pw0470@gmail.com"]

  spec.summary       = "A library for generating queue processing applications."
  spec.description   = "A library to assist in the creation of queue processing 'application as a service' entities."
  spec.homepage      = "https://github.com/free-beer/qprocessor"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/free-beer/qprocessor.git"
  spec.metadata["changelog_uri"] = "https://github.com/free-beer/qprocessor/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "aws-sdk-sqs", "~> 1.49"
  spec.add_dependency "aws-sdk-sts", "~> 1.5"
  spec.add_dependency "beaneater", "~> 1.1"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
