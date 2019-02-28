# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'migrate', '20190228092516_clean_up_noteable_id_for_notes_on_commits.rb')

describe CleanUpNoteableIdForNotesOnCommits, :migration do
  before do
    create_list(:note_on_commit, 5, noteable_id: 123)
    create(:note_on_issue)
    create(:note_on_merge_request)
    create(:note_on_project_snippet)
    create(:note_on_personal_snippet)
  end

  it 'clears noteable_id for notes on commits' do
    expect { migrate! }.to change { dirty_notes_on_commits.count }.from(5).to(0)
  end

  it 'does not clear noteable_id for other notes' do
    expect { migrate! }.not_to change { other_notes.count }
  end

  def dirty_notes_on_commits
    Note.where(noteable_type: 'Commit').where('noteable_id IS NOT NULL')
  end

  def other_notes
    Note.where("noteable_type != 'Commit' AND noteable_id IS NOT NULL")
  end
end
