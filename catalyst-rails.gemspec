Gem::Specification.new do |spec|
  spec.name        = 'catalyst-rails'
  spec.version     = '0.0.3'
  spec.date        = '2018-03-29'
  spec.summary     = 'Ruby helpers for the "catalyst" node package'
  spec.authors     = ['Dan Martens']
  spec.email       = 'dan@friendsoftheweb.com'
  spec.files       = Dir['lib/**/*']
  spec.homepage    = 'http://rubygems.org/gems/catalyst-rails'
  spec.license     = 'MIT'

  spec.add_runtime_dependency 'dry-configurable', '~> 0.7'
  spec.add_runtime_dependency 'actionview', '>= 3.0', '<= 6.0'
end
