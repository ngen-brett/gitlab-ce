# frozen_string_literal: true
module Types
  module Tree
    class TreeType < BaseObject
      graphql_name 'Tree'

      field :trees, Types::Tree::TreeEntryType.connection_type, null: false, calls_gitaly: true# 2 times
      field :submodules, Types::Tree::SubmoduleType.connection_type, null: false, calls_gitaly: true# 2 times
      field :blobs, Types::Tree::BlobType.connection_type, null: false, calls_gitaly: true# 2 times
    end
  end
end
