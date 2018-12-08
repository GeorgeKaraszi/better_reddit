# frozen_string_literal: true

module BetterReddit
  module Error
    class StandardException < StandardError
      attr_reader :message, :http_status, :http_body, :http_headers

      def initialize(message = "", http_response = nil)
        @message = message

        if http_response
          @http_headers = http_response.headers
          @http_status  = "#{http_response.status.code} => #{http_response.status.reason}"
          @http_body    = http_response.to_s
        end
      end

      def to_s
        out_message = message
        out_message += "\n(Status: #{http_status})"            unless http_status.nil?
        out_message += "\nRaw request body: #{http_body}"      unless http_body.nil?
        out_message += "\nResponse Headers: #{http_headers}\n" unless http_headers.nil?
        out_message
      end
    end
  end
end
