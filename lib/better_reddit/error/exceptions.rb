# frozen_string_literal: true

require "better_reddit/error/standard_exception"

module BetterReddit
  module Error
    class APIAuthorizationError < StandardException; end
    class APIConnectionError < StandardException; end
    class APIInvalidRequestError < StandardException; end

    class ClientInvalidRequestError < StandardException; end
    class ClientInvalidResourceError < StandardException; end

    class ClientError < StandardException
      def self.client_error(class_name, message)
        new("It looks like our client raised an #{class_name} error with message:  #{message}")
      end

      def self.missing_response_object
        new("No response was provided prior to decoding."\
            "Ensure that you make a request before attempting to decode the returning messages.")
      end
    end
  end
end
