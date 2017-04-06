require File.expand_path('../lib/stasche/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'stasche'
  gem.version     = Stasche::VERSION
  gem.authors     = ['Jon Whiteaker', 'Eric Psalmond']
  gem.email       = %w[eng@checkr.com]
  gem.summary     = 'Stash + Cache = Profit'
  gem.description = 'Utility to enable sharing objects across remote sessions.'
  gem.homepage    = 'https://github.com/checkr/stasche'
  gem.files       = Dir['lib/**/*']

  gem.required_ruby_version = '>= 2.2.3'

  gem.add_dependency 'json', '>= 1.8'
  gem.add_dependency 'redis', '>= 3.2'

  gem.add_development_dependency 'rake',  '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'database_cleaner', '~> 1.5'
end
