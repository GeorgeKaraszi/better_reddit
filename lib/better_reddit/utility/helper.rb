# frozen_string_literal: true

module BetterReddit
  module Utility
    module Helper
      module_function

      def normalize_params(params)
        symbolize_names(params)
      end

      # Formats the destination path
      # Ex: normalize_path("/foo/%<resource_id>s/bar", 101) #=> "/foo/101/bar"
      #     normalize_path("/foo/%<resource_id>s/bar", "user@example.com") #=> "/foo/user%40example.com/bar"
      def normalize_path(api_path, resource_id)
        return api_path unless resource_id

        format(api_path, resource_id: resource_id)
      end

      # Recursively traverses a Hash table to ensure keys are symbolized.
      # A necessary evil to ensure data is handled correctly throughout the library processing.
      def symbolize_names(object)
        case object
        when Hash
          {}.tap do |new_hash|
            object.each do |key, value|
              key = begin
                key.to_sym
                    rescue StandardError
                      key
              end
              new_hash[key] = symbolize_names(value)
            end
          end
        when Array
          object.map { |value| symbolize_names(value) }
        else
          object
        end.freeze
      end
    end
  end
end
