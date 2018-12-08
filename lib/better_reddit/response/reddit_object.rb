# frozen_string_literal: true

module BetterReddit
  module Response
    class RedditObject < ::OpenStruct
      def method_missing(method_name, *args, &blk)
        prefixed_method = method_name.to_s.chomp!("?")
        prefixed_method ? @table.key?(prefixed_method.to_sym) : super
      end

      def respond_to_missing?(method_name, include_all)
        method_name.to_s.end_with?("?") || super
      end
    end
  end
end
