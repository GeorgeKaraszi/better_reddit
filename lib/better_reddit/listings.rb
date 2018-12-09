# frozen_string_literal: true

module BetterReddit
  class Listings < APIResource
    api_paths base:   "%<resource_id>s.json",
              newest: "%<resource_id>s/new.json",
              best:   "%<resource_id>s/best.json",
              hot:    "%<resource_id>s/hot.json",
              top:    "%<resource_id>s/top.json",
              gilded: "%<resource_id>s/gilded.json"

    define_get_path_methods!

    def initialize(sub_reddit, **args)
      sub_reddit = "/r/#{sub_reddit}" unless sub_reddit.to_s.match?(%r{^\/?r\/})
      super(sub_reddit, args)
    end
  end
end
