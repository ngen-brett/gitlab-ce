# frozen_string_literal: true

class FeatureFlagEntity < Grape::Entity
  expose :id
  expose :active
  expose :created_at
  expose :updated_at
  expose :name
  expose :description

  expose :edit_path, if: -> (feature_flag, _) { can?(request.current_user, :update_feature_flag, feature_flag) } do |feature_flag|
    edit_project_feature_flag_path(feature_flag.project, feature_flag)
  end

  expose :delete_path, if: -> (feature_flag, _) { can?(request.current_user, :destroy_feature_flag, feature_flag) } do |feature_flag|
    delete_project_feature_flag_path(feature_flag.project, feature_flag)
  end
end
