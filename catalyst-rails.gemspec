# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'catalyst-rails'
  spec.version = '2.0.0.beta2'
  spec.date = '2021-01-04'
  spec.summary = 'Ruby helpers for the "catalyst" node package'
  spec.authors = ['Dan Martens']
  spec.email = 'dan@friendsoftheweb.com'
  spec.files = Dir['lib/**/*']
  spec.homepage = 'http://rubygems.org/gems/catalyst-rails'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_runtime_dependency 'actionview', '>= 3.0', '< 7.0'
  spec.add_runtime_dependency 'dry-configurable', '~> 0.7'
  spec.add_runtime_dependency 'sorbet-runtime', '~> 0.5.0'

  spec.add_development_dependency 'rubocop', '~> 1.7'
  spec.add_development_dependency 'sorbet', '~> 0.5.0'
end
