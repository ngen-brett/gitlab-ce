# frozen_string_literal: true
require 'singleton'

module Gitlab
  class ReleaseBlogPost
    include Singleton

    RELEASE_RSS_URL = 'https://about.gitlab.com/releases.xml'

    # Returning the RSS feed url instead of actually determining the blog_post_url via an HTTP request
    def blog_post_url
      RELEASE_RSS_URL
    end
  end
end
