module Stasche
  module Store
    class S3

      def initialize(configuration)
        credentials = Aws::Credentials.new(
          configuration.access_key_id,
          configuration.secret_access_key
        )
        @client = Aws::S3::Client.new(
          region:            configuration.region,
          credentials:       credentials,
          http_read_timeout: 10
        )
        resource = Aws::S3::Resource.new(client: @client)
        @bucket = resource.bucket(configuration.bucket)
      end

      def get(key)
        @bucket.object(key).get.body.read
      rescue Aws::S3::Errors::NoSuchKey
        nil
      end

      def set(key, value, force: false)
        fail KeyAlreadyExistsError, key if !force && @bucket.object(key).exists?
        @bucket.put_object(key: key, body: value)
        true
      end

      def del(key)
        @bucket.object(key).delete
        true
      end

      def keys(pattern)
        @bucket.objects.entries.map(&:key).select do |key|
          # Glob-style pattern matching
          File.fnmatch(pattern, key)
        end
      end

    end
  end
end
