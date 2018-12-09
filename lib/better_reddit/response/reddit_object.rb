# frozen_string_literal: true

module BetterReddit
  module Response
    class RedditObject < ::OpenStruct
      extend Forwardable

      def method_missing(method_name, *args, &blk)
        if @table.respond_to?(method_name, false)
          @table.public_send(method_name, *args, &blk)
        else
          prefixed_method = method_name.to_s.chomp!("?")
          prefixed_method ? @table.key?(prefixed_method.to_sym) : super
        end
      end

      def respond_to_missing?(method_name, include_all)
        method_name.to_s.end_with?("?") || @table.respond_to?(method_name, false) || super
      end
    end
  end
end
