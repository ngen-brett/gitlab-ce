# frozen_string_literal: true

module Gitlab
  module Template
    class GitlabCiYmlTemplate < BaseTemplate
      def content
        explanation = "# This file is a template, and might need editing before it works on your project."
        [explanation, super].join("\n")
      end

      class << self
        def extension
          '.gitlab-ci.yml'
        end

        def categories
          {
            'General' => '',
            'Pages' => 'Pages',
            'Auto deploy' => 'autodeploy'
          }
        end

        def base_dir
          Rails.root.join('lib/gitlab/ci/templates')
        end

        def finder(project = nil)
          Gitlab::Template::Finders::GlobalTemplateFinder.new(self.base_dir, self.extension, self.categories)
        end

        def dropdown_names(context)
          categories = context == 'autodeploy' ? ['Auto deploy'] : static_dropdown_names
          super().slice(*categories)
        end

        protected

        def static_dropdown_names
          %w(General Pages)
        end
      end
    end
  end
end
