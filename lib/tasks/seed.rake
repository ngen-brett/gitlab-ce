namespace :gitlab do
  namespace :seed do
    desc "GitLab | Seed | Seeds issues"
    task :issues, [:project_full_path] => :environment do |t, args|
      projects =
        if args.project_full_path
          [Project.find_by_full_path(args.project_full_path)]
        else
          Project.find_each
        end

      projects.each do |project|
        puts "\nSeeding issues for the '#{project.full_path}' project"
        seeder = Quality::Seeders::Issues.new(project_full_path: project.full_path)
        issues_created = seeder.seed(backfill_weeks: 5, average_issues_per_week: 2)
        puts "\n#{issues_created} issues created!"
      end
    end
  end
end
