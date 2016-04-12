module Stache
  module Store
    class KeyAlreadyExistsError < StandardError

      def initialize(key)
        super(
          "Key #{key} already set in stache. Use `force: true` to override."
        )
      end

    end
  end
end

require 'stache/store/redis'
