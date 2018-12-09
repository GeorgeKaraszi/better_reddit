# frozen_string_literal: true

module BetterReddit
  class APIResource
    attr_reader :client, :last_response, :resource_id

    def self.class_name
      name.split("::")[-1]
    end

    def self.api_paths(**paths)
      @api_paths ||= paths.tap { |hash| hash[:base] ||= "" }.freeze
    end

    def self.define_get_path_methods!
      api_paths.each_key do |path_key|
        define_method(path_key == :base ? :receive : path_key) do |**params|
          request(:get, api_dest: path_key, params: params)
        end
      end
    end

    private_class_method :define_get_path_methods!

    def initialize(resource_id, **args)
      @resource_id = resource_id
      @client      = Client.active_client
      authenticate!(args.delete(:username), args.delete(:password)) if args.key?(:username) && args.key?(:password)
    end

    def authenticate!(username, password)
      @client.authenticate!(username, password)
      self
    end

    protected

    def request(method, api_dest: :base, resource_id: @resource_id, params: {})
      api_path       = Utility::Helper.normalize_path(self.class.api_paths[api_dest], resource_id)
      params         = Utility::Helper.normalize_params(params)
      @last_response = @client.request!(method, api_path, params).decode_response
    end
  end
end
