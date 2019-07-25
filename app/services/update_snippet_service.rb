# frozen_string_literal: true

class UpdateSnippetService < BaseService
  include SpamCheckService
  include ServiceCounter

  attr_accessor :snippet

  def initialize(project, user, snippet, params)
    super(project, user, params)
    @snippet = snippet
  end

  def execute
    # check that user is allowed to set specified visibility_level
    new_visibility = params[:visibility_level]

    if new_visibility && new_visibility.to_i != snippet.visibility_level
      unless Gitlab::VisibilityLevel.allowed_for?(current_user, new_visibility)
        deny_visibility_level(snippet, new_visibility)
        return snippet
      end
    end

    filter_spam_check_params
    snippet.assign_attributes(params)
    spam_check(snippet, current_user)

    snippet.save.tap do |succeeded|
      usage_log if succeeded
    end
  end

  class << self
    def usage_key
      'snippets/update_service'
    end
  end
end
