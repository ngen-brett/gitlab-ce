# frozen_string_literal: true

module Mutations
  module Notes
    class Destroy < Base
      graphql_name 'DestroyNote'

      authorize :admin_note

      argument :id,
                GraphQL::ID_TYPE,
                required: true,
                description: 'The global id of the note to destroy'

      def resolve(id:)
        note = authorized_find!(id: id)

        project = ::Gitlab::Graphql::Loaders::BatchModelLoader.new(Project, note.project_id).find

        ::Notes::DestroyService.new(project, current_user).execute(note)

        {
          errors: []
        }
      end
    end
  end
end
