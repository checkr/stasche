require 'json'
require 'securerandom'
require 'stasche/configuration'
require 'stasche/store'

module Stasche
  class Client

    attr_reader :store, :namespace

    def initialize(options = {})
      configuration = Configuration.new(
        *options.values_at(*Configuration.members)
      )

      yield configuration if block_given?

      type  = configuration.store || :redis
      klass = Store.const_get(type.capitalize)

      @store = klass.new(url: configuration.url)
      @namespace = configuration.namespace || 'stasche'
    end

    def get(key, expire: false)
      value = store.get("#{namespace}:#{key}")
      del(key) if expire
      value.nil? || value.empty? ? nil : JSON.parse(value)['value']
    end

    def set(values, options = {})
      last_value = values.inject(nil) do |_, (key, value)|
        json = { value: value }.to_json
        store.set("#{namespace}:#{key}", json, options)
        key
      end

      result = store.set("#{namespace}_last", last_value, force: true)

      result == 'OK'
    end

    def ls(pattern = '*')
      store.keys("#{namespace}:#{pattern}").map do |key|
        key.gsub(/^#{namespace}:/, '')
      end
    end

    def count
      ls.count
    end

    def push(value)
      key = SecureRandom.urlsafe_base64
      set(key => value)
      key
    end

    alias << push

    def peek
      get(store.get("#{namespace}_last"))
    end

    alias last peek

    def pop
      last_key = store.get("#{namespace}_last")
      value = get(last_key)
      store.del("#{namespace}:#{last_key}")
      value
    end

    def del(key)
      store.del("#{namespace}:#{key}")
    end

  end
end
