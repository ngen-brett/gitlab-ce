# frozen_string_literal: true

module Types
  class GroupType < BaseObject
    graphql_name 'Group'

    authorize :read_group

    expose_permissions Types::PermissionTypes::Group

    field :id, GraphQL::ID_TYPE, null: false
    field :web_url, GraphQL::STRING_TYPE, null: true
    field :name, GraphQL::STRING_TYPE, null: false

    field :path, GraphQL::STRING_TYPE, null: false
    field :description, GraphQL::STRING_TYPE, null: true
    field :visibility, GraphQL::STRING_TYPE, null: true

    field :lfs_enabled, GraphQL::BOOLEAN_TYPE, null: true, resolve: -> (group, args, ctx) do
      group.lfs_enabled?
    end

    field :avatar_url, GraphQL::STRING_TYPE, null: true, resolve: -> (group, args, ctx) do
      group.avatar_url(only_path: false)
    end

    field :request_access_enabled, GraphQL::BOOLEAN_TYPE, null: true
    field :full_path, GraphQL::ID_TYPE, null: false
    field :full_name, GraphQL::STRING_TYPE, null: false

    if ::Group.supports_nested_objects?
      field :parent_id, GraphQL::ID_TYPE, null: true
    end
  end
end
