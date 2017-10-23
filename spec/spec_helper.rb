if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'

  CodeClimate::TestReporter.start
end

require 'database_cleaner'
require 'redis'
require 'stasche'

class Encrypter

  def self.encrypt(_key, plaintext)
    plaintext
  end

  def self.decrypt(_key, ciphertext)
    ciphertext
  end

end

RSpec.configure do |config|
  config.color = true
  config.tty   = true
  config.order = :random

  config.disable_monkey_patching!

  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end
