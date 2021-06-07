require_relative 'lib/content_manager_api/version'

Gem::Specification.new do |spec|
  spec.name          = "content_manager_api"
  spec.version       = ContentManagerApi::VERSION
  spec.authors       = ["IT Department"]
  spec.email         = ["it@kpb.us"]

  spec.summary       = %q{a simple interface for content manager}
  spec.description   = %q{a simple interface for content manager customized for us}
  spec.homepage      = "http://www.kpb.us"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/KPB-US/content_manager_api.git"
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rest-client'
  spec.add_dependency 'ruby-ntlm'
end
