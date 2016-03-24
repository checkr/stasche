module Stache
  STACHE_NAMESPACE = 'stache'
  STACHE_LAST_KEY = 'stache_last_key'

  def self.stash(obj, key: SecureRandom.urlsafe_base64, ttl: 1.hour, force: false)
    serialized = obj.to_json
    ns_key = "#{STACHE_NAMESPACE}#{key}"
    success = store.set(ns_key, serialized, ex: ttl, nx: !force)
    fail Error, "Key #{key} already set in stache store, call with `force: true` to override" unless success
    store.set(STACHE_LAST_KEY, key)
    key
  end

  def self.pop(key = store.get(STACHE_LAST_KEY), unset: false)
    key.prepend(STACHE_NAMESPACE)
    serialized = store.get(key)
    store.del(key) if unset
    serialized.blank? ? nil : JSON.load(serialized)
  end

  def self.ls(key: '*')
    store.keys("#{STACHE_NAMESPACE}#{key}")
  end

  def self.store
    @store ||= Redis.new(url: ENV['STACHE_REDIS_URL'])
  end
end
