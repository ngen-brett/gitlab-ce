# frozen_string_literal: true

module Gitlab
  module CycleAnalytics
    module Summary
      module Group
        class Issue < Base
          def initialize(group:, from:, current_user:)
            @group = group
            @from = from
            @current_user = current_user
          end

          def title
            n_('New Issue', 'New Issues', value)
          end

          def value
            @value ||= IssuesFinder.new(@current_user, group_id: @group.id).execute.created_after(@from).count
          end
        end
      end
    end
  end
end
