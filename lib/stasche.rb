require 'stasche/client'
require 'redis'
require 'aws-sdk'

module Stasche
  extend SingleForwardable

  delegate Client.public_instance_methods(false) => :client

  def self.configure(&config)
    Thread.current[:stasche_instance] = Client.new(&config)
  end

  def self.client
    Thread.current[:stasche_instance] or
      fail 'Stasche not configured'
  end
end
