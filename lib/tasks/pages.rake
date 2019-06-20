namespace :pages do
  desc "Makes all pages sites public(needed to enable access-control on gitlab.com)"
  task make_all_public: :environment do
    features = ProjectFeature.arel_table
    projects_to_update = Project.with_project_feature.where(features[:pages_access_level].lt(ProjectFeature::PUBLIC))

    projects_to_update.find_each do |project|
      next unless project.pages_deployed?

      project.project_feature.update(pages_access_level: ProjectFeature::PUBLIC)
      ::Projects::UpdatePagesConfigurationService.new(project).execute
    end
  end
end
