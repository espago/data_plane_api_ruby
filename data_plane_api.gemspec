# frozen_string_literal: true

require_relative 'lib/data_plane_api/version'

::Gem::Specification.new do |spec|
  spec.name = 'data_plane_api'
  spec.version = ::DataPlaneApi::VERSION
  spec.authors = ['Mateusz Drewniak', 'Espago']
  spec.email = ['m.drewniak@espago.com']

  spec.summary = 'Ruby gem which covers a limited subset of the HAProxy Data Plane API.'
  spec.description = 'Ruby gem which covers a limited subset of the HAProxy Data Plane API.'
  spec.homepage = 'https://github.com/espago/data_plane_api_ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/espago/data_plane_api_ruby'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = ::Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| ::File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'faraday', '~> 2.7'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
