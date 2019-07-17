Gem::Specification.new do |spec|
  spec.name        = 'catalyst-rails'
  spec.version     = '0.1.0'
  spec.date        = '2019-07-17'
  spec.summary     = 'Ruby helpers for the "catalyst" node package'
  spec.authors     = ['Dan Martens']
  spec.email       = 'dan@friendsoftheweb.com'
  spec.files       = Dir['lib/**/*']
  spec.homepage    = 'http://rubygems.org/gems/catalyst-rails'
  spec.license     = 'MIT'

  spec.add_runtime_dependency 'dry-configurable', '~> 0.7'
  spec.add_runtime_dependency 'actionview', '>= 3.0', '<= 6.0'
  spec.add_runtime_dependency 'sorbet-runtime'

  spec.add_development_dependency 'sorbet'
end
