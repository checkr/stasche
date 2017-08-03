module Stasche
  module Store
    class Redis

      attr_reader :url

      def initialize(url: nil)
        @url = url
      end

      def get(key)
        cache.get(key)
      end

      def set(key, value, ttl: 3600, force: false)
        ok = cache.set(key, value, ex: ttl, nx: !force)

        fail KeyAlreadyExistsError, key unless ok

        ok
      end

      def del(key)
        cache.del(key)
      end

      def keys(pattern)
        cache.keys(pattern)
      end

      def lpop(key)
        cache.lpop(key)
      end

      def lpush(key, value)
        cache.lpush(key, value)
      end

      private

      def cache
        @cache ||= begin
          require 'redis'

          ::Redis.new(url: url)
        end
      end

    end
  end
end
