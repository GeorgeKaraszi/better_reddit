# frozen_string_literal: true

require "http"
require "ostruct"
require "oj"

require "better_reddit/version"

# Exception Classes Container
require "better_reddit/error/exceptions"

# Utility Helper classes
require "better_reddit/utility/helper"

# Net and responses classes
require "better_reddit/response/reddit_object"
require "better_reddit/response/reddit_decoder"
require "better_reddit/client"

# Query Classes
require "better_reddit/api_resource"
require "better_reddit/listings"

module BetterReddit
  @enabled            = true
  @raise_http_errors  = true
  @write_timeout      = 5
  @read_timeout       = 5
  @connect_timeout    = 5
  @retry_attempts     = 2
  @reddit_url         = "https://ssl.reddit.com"

  class << self
    attr_accessor :enabled, :write_timeout, :read_timeout, :connect_timeout,
                  :raise_http_errors, :reddit_url, :retry_attempts

    def enabled?
      @enabled
    end

    def raise_http_errors?
      @raise_http_errors
    end
  end
end
