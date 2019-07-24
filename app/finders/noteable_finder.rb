# frozen_string_literal: true

class NoteableFinder
  def initialize(user, project, params)
    @user = user
    @project = project
    @params = params
  end

  def find
    return @target if defined?(@target)

    target_type = @params[:target_type]
    target_id   = @params[:target_id]
    target_iid  = @params[:target_iid]

    return @target = nil unless target_type
    return @target = nil unless target_id || target_iid

    @target =
      if target_type == "commit"
        if Ability.allowed?(@current_user, :download_code, @project)
          @project.commit(target_id)
        end
      else
        noteable_for_type_by_id(target_type, target_id, target_iid)
      end
  end

  def noteables_for_type
    case noteable_type
    when "issue"
      IssuesFinder.new(@current_user, project_id: @project.id).execute # rubocop: disable CodeReuse/Finder
    when "merge_request"
      MergeRequestsFinder.new(@current_user, project_id: @project.id).execute # rubocop: disable CodeReuse/Finder
    when "snippet", "project_snippet"
      SnippetsFinder.new(@current_user, project: @project).execute # rubocop: disable CodeReuse/Finder
    when "personal_snippet"
      PersonalSnippet.all
    else
      raise "invalid target_type '#{noteable_type}'"
    end
  end

  private

  def noteable_for_type_by_id(type, id, iid)
    query = if id
              { id: id }
            else
              { iid: iid }
            end

    noteables_for_type(type).find_by!(query) # rubocop: disable CodeReuse/ActiveRecord
  end
end
