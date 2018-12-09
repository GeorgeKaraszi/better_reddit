# frozen_string_literal: true

module BetterReddit
  class Client
    attr_accessor :conn
    attr_reader   :response, :response_body

    AUTH_PATH = "/api/login.json"

    def self.active_client
      Thread.current[:reddit_client] || default_client
    end

    def self.default_client
      Thread.current[:reddit_default_client] ||= Client.new(default_conn)
    end

    def self.default_conn
      Thread.current[:default_conn] ||= begin
        HTTP.headers("User-Agent" => "better-reddit API client by George P. [v.#{BetterReddit::VERSION}]")
            .accept("application/json")
            .follow
            .timeout(
              connect: BetterReddit.connect_timeout,
              write:   BetterReddit.write_timeout,
              read:    BetterReddit.read_timeout
            )
      end
    end

    def initialize(conn = nil)
      @conn = conn || self.class.default_conn
    end

    def authenticate!(username, password)
      request!(:post, AUTH_PATH, user: username, passwd: password)
      @conn = @conn.cookies(@response.cookies)
      self
    end

    def request!(verb_method, path, params = {})
      capture_response!(verb_method.to_sym, path, params, BetterReddit.retry_attempts)
      raise_status_error! unless @response.status.success?
      self
    end

    def decode_response
      raise Error::ClientError.missing_response_object unless @response

      Response::RedditDecoder.new(@response)
    end
    alias parse decode_response

    protected

    def capture_response!(verb, path, params, retry_count = 2)
      @response = with_persisted_connection! do |http|
        if verb == :get
          http.request(verb, path, params: params)
        else
          http.request(verb, path, form: params)
        end.flush
      end

      if hit_rate_limit?
        wait_for_limit!
        raise Error::APIConnectionError.rate_limit
      end
    rescue StandardError
      retry_count ||= 0
      retry_count -= 1
      retry if retry_count.positive?
      raise
    end

    private

    def with_persisted_connection!
      @conn.persistent(BetterReddit.reddit_url) do |http|
        yield(http)
      end
    end

    def hit_rate_limit?
      return unless BetterReddit.wait_for_rate_limit?

      remaining_limit = @response.headers["X-Ratelimit-Remaining"]
      !remaining_limit.nil? && remaining_limit.to_i.zero?
    end

    def wait_for_limit!
      return unless BetterReddit.wait_for_rate_limit?

      sleep @response.headers["X-Ratelimit-Reset"].to_i
    end

    def raise_status_error!
      return unless BetterReddit.raise_http_errors?

      case @response.status.code
      when 401
        raise Error::APIAuthorizationError.new("Authorization Error", @response)
      when 500..502
        raise Error::APIConnectionError.new("Problem with server response", @response)
      else
        false
      end
    end

    def destination_path(path)
      path = "/#{path}" unless path.start_with?("/")
      path.end_with?(".json") ? path : "#{path}.json"
    end
  end
end
