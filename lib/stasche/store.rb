module Stasche
  module Store
    class KeyAlreadyExistsError < StandardError

      def initialize(key)
        super(
          "Key #{key} already set in stasche. Use `force: true` to override.\n"\
          "Example: Stasche.set({foo: 'bar'}, force: true)"
        )
      end

    end
  end
end

require 'stasche/store/redis'
require 'stasche/store/s3'
