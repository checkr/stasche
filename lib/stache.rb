require 'stache/client'

module Stache
  extend SingleForwardable

  delegate Client.public_instance_methods(false) => :client

  def self.configure(&config)
    Thread.current[:stache_instance] = Client.new(&config)
  end

  def self.client
    Thread.current[:stache_instance] or
      fail 'Stache not configured'
  end
end
