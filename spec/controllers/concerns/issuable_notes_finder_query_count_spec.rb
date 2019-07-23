# frozen_string_literal: true

require 'spec_helper'

describe 'Query counts for Issuable' do
  let!(:group) { create(:group) }
  let!(:user) { create(:group_member, :owner, group: group, user: create(:user)).user }
  let!(:project) { create(:project, namespace: group) }
  let!(:issue) { create(:issue, project: project) }
  let!(:note) { create(:discussion_note_on_issue, noteable: issue, project: project, author: user) }

  let(:old_module) do
    Module.new do

      # Former implementation
      def discussions
        notes = issuable.discussion_notes
                    .inc_relations_for_view
                    .includes(:noteable)
                    .fresh

        if notes_filter != UserPreference::NOTES_FILTERS[:only_comments]
          notes = ResourceEvents::MergeIntoNotesService.new(issuable, current_user).execute(notes)
        end

        notes = prepare_notes_for_rendering(notes)
        notes = notes.reject { |n| n.cross_reference_not_visible_for?(current_user) }

        discussions = Discussion.build_collection(notes, issuable)

        render json: discussion_serializer.represent(discussions, context: self)
      end
    end
  end

  it 'does not increase query count' do
    klass = Class.new do
      attr_reader :current_user, :project, :issuable

      def self.before_action(action, params = nil)
      end

      include IssuableActions

      def initialize(issuable, project, user)
        @issuable = issuable
        @project = project
        @current_user = user
      end

      def params
        {
          notes_filter: 1
        }
      end

      def prepare_notes_for_rendering(notes)
        notes
      end

      def render(options)
      end
    end
    discussions_provider = klass.new(issue, project, user)
    old_count = ActiveRecord::QueryRecorder.new { discussions_provider.discussions }.count

    klass.prepend(old_module)
    discussions_provider = klass.new(issue, project, user)
    new_count = ActiveRecord::QueryRecorder.new { discussions_provider.discussions }.count

    expect(old_count).to eq(new_count)
  end
end
