# frozen_string_literal: true

module Types
  class GroupType < BaseObject
    graphql_name 'Group'

    authorize :read_group

    expose_permissions Types::PermissionTypes::Group

    field :id, GraphQL::ID_TYPE, null: false

    field :path, GraphQL::STRING_TYPE, null: false
    field :name, GraphQL::STRING_TYPE, null: false
    field :full_path, GraphQL::ID_TYPE, null: false
    field :full_name, GraphQL::STRING_TYPE, null: false

    field :description, GraphQL::STRING_TYPE, null: true

    field :web_url, GraphQL::STRING_TYPE, null: true
    field :file_template_project_id, GraphQL::ID_TYPE, null: true
    field :parent_id, GraphQL::ID_TYPE, null: true
    field :shared_runners_minutes_limit, GraphQL::INT_TYPE, null: true
    field :extra_shared_runners_minutes_limit, GraphQL::INT_TYPE, null: true
    field :visibility, GraphQL::STRING_TYPE, null: true
    field :request_access_enabled, GraphQL::BOOLEAN_TYPE, null: true

    field :avatar_url, GraphQL::STRING_TYPE, null: true, resolve: -> (group, args, ctx) do
      group.avatar_url(only_path: false)
    end
  end
end
