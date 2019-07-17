# frozen_string_literal: true

module API
  # Internal access API
  module Internal
    class Pages < Grape::API
      before { authenticate_gitlab_pages_request! }

      helpers do
        def authenticate_gitlab_pages_request!
          unauthorized! unless Gitlab::Pages.verify_api_request(headers)
        end
      end

      namespace 'internal' do
        namespace 'pages' do
          desc 'Get GitLab Pages domain configuration by hostname' do
            detail 'This feature was introduced in GitLab 12.2.'
          end
          params do
            requires :host, type: String, desc: 'The host to query for'
          end
          get "/" do
            if namespace = Namespace.find_by_pages_host(params[:host])
              present namespace, with: Entities::Internal::NamespaceDomain, prefix: namespace.full_path
            elsif domain = PagesDomain.find_by_domain(params[:host])
              present domain, with: Entities::Internal::PagesDomain, prefix: domain.project.full_path
            else
              status :not_found
            end
          end
        end
      end
    end
  end
end
