# frozen_string_literal: true

class NotesFinder
  FETCH_OVERLAP = 5.seconds

  # Used to filter Notes
  # When used with target_type and target_id this returns notes specifically for the controller
  #
  # Arguments:
  #   current_user - which user check authorizations with
  #   project - which project to look for notes on
  #   params:
  #     target_type: string
  #     target_id: integer
  #     last_fetched_at: time
  #     search: string
  #
  def initialize(project, current_user, params = {})
    @project = project
    @current_user = current_user
    @params = params
  end

  def execute
    notes = init_collection
    notes = since_fetch_at(notes)
    notes = notes.with_notes_filter(@params[:notes_filter]) if notes_filter?

    notes.fresh
  end

  private

  def target
    @target = params[:target]
    @target = noteable_finder.execute
  end

  def init_collection
    return [] unless target

    notes_on_target
  end

  def target_type
    @params[:target_type]
  end

  def noteable_finder
    @noteable_finder ||= NoteableFinder.new(@current_user, @project, @params).find if @target.nil?
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def notes_for_type(noteable_type)
    if noteable_type == "commit"
      if Ability.allowed?(@current_user, :download_code, @project)
        @project.notes.where(noteable_type: 'Commit')
      else
        Note.none
      end
    else
      noteables = noteable_finder.noteables_for_type
      @project.notes.where(noteable_type: noteables.base_class.name, noteable_id: noteables.reorder(nil))
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def notes_on_target
    if target.respond_to?(:related_notes)
      target.related_notes
    else
      target.notes
    end
  end

  # Searches for notes matching the given query.
  #
  # This method uses ILIKE on PostgreSQL and LIKE on MySQL.
  #
  def search(notes)
    query = @params[:search]
    return notes unless query

    notes.search(query)
  end

  # Notes changed since last fetch
  # Uses overlapping intervals to avoid worrying about race conditions
  def since_fetch_at(notes)
    return notes unless @params[:last_fetched_at]

    # Default to 0 to remain compatible with old clients
    last_fetched_at = Time.at(@params.fetch(:last_fetched_at, 0).to_i)
    notes.updated_after(last_fetched_at - FETCH_OVERLAP)
  end

  def notes_filter?
    @params[:notes_filter].present?
  end
end
