# frozen_string_literal: true

module BetterReddit
  module Response
    class RedditDecoder
      extend Forwardable
      attr_reader :raw_response, :data, :status

      def_delegators :@data, :dig, :method_missing

      def initialize(reddit_response)
        raise Error::ClientInvalidResourceError unless reddit_response.is_a?(HTTP::Response)

        @raw_response = reddit_response
        @status       = @raw_response.status
        @data         = Oj.sc_parse(RedditObjectParser.new, @raw_response.to_s).freeze
        freeze
      end

      def valid?
        @status.success?
      end

      def invalid?
        !valid?
      end

      def inspect
        "#<#{self.class}:0x#{object_id.to_s(16)}> @status=#{@status.inspect} @data=#{@data.inspect}"
      end
      alias to_s inspect

      class RedditObjectParser < ::Oj::ScHandler
        # OJ callback when a hash is initialized.
        def hash_start
          RedditObject.new
        end

        # OJ callback when a Hash's key requires transformation.
        def hash_key(key)
          key.downcase
        end

        # OJ callback when a hash is setting a new key value.
        def hash_set(hash, key, value)
          hash[key] = value.freeze
        end

        # OJ callback when an Array is initialized.
        def array_start
          []
        end

        # OJ callback when an Array is being appended to.
        def array_append(array, value)
          array << value.freeze
        end
      end
    end
  end
end
