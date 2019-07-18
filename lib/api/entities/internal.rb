# frozen_string_literal: true

module API
  module Entities
    module Internal
      class PagesLookupPath < Grape::Entity
        expose :id, as: :project_id
        expose :private_pages?, as: :access_control

        expose :https_only do |project, opts|
          domain_https = opts[:domain] ? opts[:domain].https? : true
          project.pages_https_only? && domain_https
        end

        expose :path do |project|
          File.join(project.full_path, 'public/')
        end

        expose :prefix do |project, opts|
          if project.pages_group_root?
            '/'
          else
            project.full_path.delete_prefix(opts[:prefix]) + '/'
          end
        end
      end

      class PagesDomain < Grape::Entity
        expose :certificate
        expose :key
        expose :lookup_paths do |domain, opts|
          PagesLookupPath.represent([domain.project], opts.merge(domain: domain))
        end
      end

      class NamespaceDomain < Grape::Entity
        expose :lookup_paths, using: PagesLookupPath do |group|
          group.all_projects.with_pages.sort_by(&:pages_url).reverse
        end
      end
    end
  end
end
