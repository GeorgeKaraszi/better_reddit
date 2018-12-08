# frozen_string_literal: true

module BetterReddit
  class Client
    attr_accessor :conn
    attr_reader   :response

    def self.active_client
      Thread.current[:reddit_client] || default_client
    end

    def self.default_client
      Thread.current[:reddit_default_client] ||= Client.new(default_conn)
    end

    def self.default_conn
      Thread.current[:reddit_default_conn] ||= begin
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

    def request(verb_method, path, params = {})
      capture_response! { send(verb_method.to_sym, destination_url(path), params) }
      raise_status_error! unless @response.status.success?
      self
    end

    def decode_response
      raise Error::ClientError.missing_response_object unless @response

      Response::RedditDecoder.new(@response)
    end

    protected

    def capture_response!(retry_count = 2)
      @response = yield
    rescue StandardError
      retry_count ||= 0
      retry_count -= 1
      retry if retry_count.positive?
      raise
    end

    def get(url, params = {})
      @conn.get(url, params: params)
    end

    def post(url, params = {})
      @conn.post(url, json: params)
    end

    def patch(url, params = {})
      @conn.patch(url, json: params)
    end

    def put(url, params = {})
      @conn.put(url, json: params)
    end

    def delete(url, params = {})
      @conn.delete(url, json: params)
    end

    private

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

    def destination_url(path)
      path = path.start_with?("/")   ? path : "/#{path}"
      path = path.end_with?(".json") ? path : "#{path}.json"
      "#{BetterReddit.reddit_url}#{path}"
    end
  end
end
