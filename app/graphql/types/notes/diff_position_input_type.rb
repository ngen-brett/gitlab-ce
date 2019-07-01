# frozen_string_literal: true

module Types
  module Notes
    class DiffPositionInputType < BaseInputObject
      graphql_name 'DiffPositionInput'

      argument :head_sha, GraphQL::STRING_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :head_sha)
      argument :base_sha,  GraphQL::STRING_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :base_sha)
      argument :start_sha, GraphQL::STRING_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :start_sha)

      argument :file_path, GraphQL::STRING_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :file_path)
      argument :old_path, GraphQL::STRING_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :old_path)
      argument :new_path, GraphQL::STRING_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :new_path)

      argument :position_type, Types::Notes::PositionTypeEnum, required: true,
               description: copy_field_description(Types::Notes::DiffPositionType, :position_type)

      # Text arguments
      argument :old_line, GraphQL::INT_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :old_line)
      argument :new_line, GraphQL::INT_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :new_line)

      # Position arguments
      argument :x, GraphQL::INT_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :x)
      argument :y, GraphQL::INT_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :y)
      argument :width, GraphQL::INT_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :width)
      argument :height, GraphQL::INT_TYPE, required: false,
               description: copy_field_description(Types::Notes::DiffPositionType, :height)
    end
  end
end
