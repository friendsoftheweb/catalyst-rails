Gem::Specification.new do |spec|
  spec.name        = 'catalyst-rails'
  spec.version     = '0.1.3'
  spec.date        = '2019-08-14'
  spec.summary     = 'Ruby helpers for the "catalyst" node package'
  spec.authors     = ['Dan Martens']
  spec.email       = 'dan@friendsoftheweb.com'
  spec.files       = Dir['lib/**/*']
  spec.homepage    = 'http://rubygems.org/gems/catalyst-rails'
  spec.license     = 'MIT'

  spec.add_runtime_dependency 'dry-configurable', '~> 0.7'
  spec.add_runtime_dependency 'actionview', '>= 3.0', '< 8.0'
  spec.add_runtime_dependency 'sorbet-runtime', '~> 0.5.0'

  spec.add_development_dependency 'sorbet', '~> 0.5.0'
end
