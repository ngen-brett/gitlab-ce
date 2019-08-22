# frozen_string_literal: true

module Gitlab
  module SlashCommands
    class IssueClose < IssueCommand
      def self.match(text)
        /\Aissue\s+close\s+#{Issue.reference_prefix}?(?<iid>\d+)/.match(text)
      end

      def self.help_message
        "issue close <id>"
      end

      def self.allowed?(project, user)
        can?(user, :update_issue, project)
      end

      def execute(match)
        issue = find_by_iid(match[:iid])

        if issue
          close_issue(issue: issue)

          present(issue)
        else
          Gitlab::SlashCommands::Presenters::Access.new.not_found
        end
      end

      private

      def close_issue(issue:)
        Issues::CloseService.new(project, current_user).execute(issue)
      end

      def present(issue)
        Gitlab::SlashCommands::Presenters::IssueClose.new(issue).present
      end
    end
  end
end
