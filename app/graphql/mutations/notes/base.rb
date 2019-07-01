# frozen_string_literal: true

module Mutations
  module Notes
    class Base < BaseMutation
      field :note,
            Types::Notes::NoteType,
            null: true,
            description: 'The note after mutation'

      private

      def find_object(id:)
        GitlabSchema.object_from_id(id)
      end
    end
  end
end
