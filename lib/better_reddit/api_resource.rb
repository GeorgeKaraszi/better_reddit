# frozen_string_literal: true

module BetterReddit
  class APIResource
    def self.class_name
      name.split("::")[-1]
    end

    def self.api_paths(**paths)
      @api_paths ||= paths.tap { |hash| hash[:base] ||= "" }.freeze
    end

    def self.request(method, api_dest: :base, resource_id: nil, params: {})
      api_path = Utility::Helper.normalize_path(api_paths[api_dest], resource_id)
      params   = Utility::Helper.normalize_params(params)

      Client.active_client.request(method, api_path, params).decode_response
    end

    private_class_method :request

    def self.define_get_path_methods!
      api_paths.each_key do |path_key|
        if path_key == :base
          define_singleton_method(:receive) do |resource_id, **params|
            request(:get, resource_id: resource_id, params: params)
          end
        else
          define_singleton_method(path_key) do |resource_id, **params|
            request(:get, resource_id: resource_id, api_dest: path_key, params: params)
          end
        end
      end
    end

    private_class_method :define_get_path_methods!
  end
end
