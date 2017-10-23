module Stasche
  module Store
    class Redis

      attr_reader :url

      def initialize(configuration)
        @url = configuration[:url]
      end

      def get(key)
        cache.get(key)
      end

      def set(key, value, ttl: 3600, force: false)
        ok = cache.set(key, value, ex: ttl, nx: !force)

        fail KeyAlreadyExistsError, key unless ok

        ok == 'OK'
      end

      def del(key)
        cache.del(key)
      end

      def keys(pattern)
        cache.keys(pattern)
      end

      private

      def cache
        @cache ||= ::Redis.new(url: url)
      end

    end
  end
end
