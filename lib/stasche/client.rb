require 'json'
require 'securerandom'
require 'stasche/configuration'
require 'stasche/store'

module Stasche
  class Client

    RPC_RATELIMIT = 0.1

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

    def rpc(name)
      loop do
        task_id      = wait_for_rpc_request(name)
        args, kwargs = retrieve_rpc_request(name, task_id)

        begin
          res = build_rpc_response(name, task_id, false, yield(*args, **kwargs))
        rescue Interrupt
          store.del("#{namespace}:#{name}")
          break
        rescue => e
          res = build_rpc_response(name, task_id, true, e.to_s)
        end
        set(res, force: true)
      end
    end

    def call(name, *args, **kwargs)
      task_id = SecureRandom.urlsafe_base64
      set({ "#{name}:#{task_id}:args" => [args, kwargs] }, force: true)
      store.lpush("#{namespace}:#{name}", task_id)
      sleep(RPC_RATELIMIT) until get("#{name}:#{task_id}:ready")
      del("#{name}:#{task_id}:ready")
      val = get("#{name}:#{task_id}:value", expire: true)
      fail val if get("#{name}:#{task_id}:error", expire: true)
      val
    end

    private

    def wait_for_rpc_request(name)
      loop do
        sleep(RPC_RATELIMIT)
        task_id = store.lpop("#{namespace}:#{name}")
        return task_id unless task_id.nil?
      end
    end

    def retrieve_rpc_request(name, task_id)
      get("#{name}:#{task_id}:args", expire: true)
    end

    def build_rpc_response(name, task_id, error, value)
      {
        "#{name}:#{task_id}:ready" => true,
        "#{name}:#{task_id}:error" => error,
        "#{name}:#{task_id}:value" => value
      }
    end

  end
end
