# frozen_string_literal: true

module Gitlab
  module Danger
    class Teammate
      attr_reader :name, :username, :role, :projects

      def initialize(options = {})
        @name = options['name']
        @username = options['username']
        @role = options['role']
        @projects = options['projects']
      end

      def markdown_name
        "[#{name}](https://gitlab.com/#{username}) (`@#{username}`)"
      end

      def in_project?(name)
        projects&.has_key?(name)
      end

      # Traintainers also count as reviewers
      def reviewer?(project, category)
        has_capability?(project, category, :reviewer) ||
          traintainer?(project, category)
      end

      def traintainer?(project, category)
        has_capability?(project, category, :trainee_maintainer)
      end

      def maintainer?(project, category)
        has_capability?(project, category, :maintainer)
      end

      private

      def has_capability?(project, category, kind)
        case category
        when Symbol
          capabilities(project).include?("#{kind} #{category}")
        when Array
          # If the category looks like %i[test Manage], then we find
          # Test Automation Engineer, Manage
          if category.first == :test
            role.include?('Test Automation Engineer') &&
              capabilities(project).include?("#{kind} #{category.last}")
          # Otherwise we just see if any of them will match
          else
            category.any? do |one_cat|
              capabilities(project).include?("#{kind} #{one_cat}")
            end
          end
        else
          raise "Unknown category: #{category}"
        end
      end

      def capabilities(project)
        Array(projects.fetch(project, []))
      end
    end
  end
end
