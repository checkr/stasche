if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'

  CodeClimate::TestReporter.start
end

require 'stache'

RSpec.configure do |config|
  config.color = true
  config.tty   = true
  config.order = :random

  config.disable_monkey_patching!
end
