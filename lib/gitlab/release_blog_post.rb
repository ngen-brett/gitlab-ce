# frozen_string_literal: true
require 'singleton'

module Gitlab
  class ReleaseBlogPost
    include Singleton

    attr_reader :url

    RELEASE_RSS_URL = 'https://about.gitlab.com/releases.xml'.freeze

    def fetch_blog_post_url(version)
      response = Gitlab::HTTP.get(RELEASE_RSS_URL, verify: false)
      if response.code == 200
        response['feed']['entry'].each do |entry|
          if entry['release'] == version
            return entry['id']
          elsif display_previous_release_post? && entry['release'][/\d+/] == version
            return entry['id']
          end
        end
        nil
      end
    end

    def initialize
      version = Gitlab.final_release? ? Gitlab.minor_release : Gitlab.previous_release
      @url = fetch_blog_post_url(version)
    end

    def display_previous_release_post?
      Gitlab.new_major_release? && !Gitlab.final_release?
    end
  end
end
