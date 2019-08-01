# frozen_string_literal: true

class AddGitlabInstanceAdministrationProject < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    SelfMonitoring::Project::CreateService.new.execute
  end

  def down
    project_id = Gitlab::CurrentSettings.current_application_settings.instance_administration_project_id
    if project_id
      Project.find(project_id).destroy!
    end
  end
end
