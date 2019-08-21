# frozen_string_literal: true

module Types
  class RootStorageStatisticsType < BaseObject
    graphql_name 'RootStorageStatistics'

    authorize :read_statistics

    field :storage_size, GraphQL::INT_TYPE, null: false
    field :repository_size, GraphQL::INT_TYPE, null: false
    field :lfs_objects_size, GraphQL::INT_TYPE, null: false
    field :build_artifacts_size, GraphQL::INT_TYPE, null: false
    field :packages_size, GraphQL::INT_TYPE, null: false
    field :wiki_size, GraphQL::INT_TYPE, null: true
  end
end
