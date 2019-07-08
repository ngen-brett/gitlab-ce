# frozen_string_literal: true

module Gitlab
  module CycleAnalytics
    module Summary
      module Group
        class Deploy < Base
          def title
            n_('Deploy', 'Deploys', value)
          end

          def value
            @value ||= find_deployments
          end

          private

          def find_deployments
            deployments = Deployment.joins(:project)
              .where(projects: { namespace_id: @group.id })
              .where("deployments.created_at > ?", @from)
            deployments = deployments.where(projects: { name: @options[:projects] }) if @options[:projects]
            deployments.success.count
          end
        end
      end
    end
  end
end
