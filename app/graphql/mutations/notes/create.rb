# frozen_string_literal: true

module Mutations
  module Notes
    class Create < Base
      graphql_name 'CreateNote'

      authorize :create_note

      argument :noteable_id,
                GraphQL::ID_TYPE,
                required: true,
                description: 'The global id of the resource to add a note to'

      argument :type,
                Types::Notes::NoteTypeEnum,
                required: true,
                description: 'The type of note'

      argument :body,
                GraphQL::STRING_TYPE,
                required: true,
                description: copy_field_description(Types::Notes::NoteType, :body)

      argument :position,
                Types::Notes::DiffPositionInputType,
                required: false,
                description: copy_field_description(Types::Notes::NoteType, :position)

      def resolve(args)
        noteable = authorized_find!(id: args[:noteable_id])

        check_object_is_noteable!(noteable)

        project = ::Gitlab::Graphql::Loaders::BatchModelLoader.new(Project, noteable.project_id).find

        note = ::Notes::CreateService.new(
          project,
          current_user,
          create_note_params(noteable, args.to_h)
        ).execute

        {
          note: (note if note.persisted?),
          errors: errors_on_object(note)
        }
      end

      private

      # Called by mutations methods after performing an authorization check
      # of an awardable object.
      def check_object_is_noteable!(object)
        unless object.is_a?(Noteable)
          raise Gitlab::Graphql::Errors::ResourceNotAvailable,
                'Cannot add notes to this resource'
        end
      end

      def create_note_params(noteable, args)
        {
          noteable: noteable,
          note: args[:body],
          type: args[:type],
          position: position(noteable, args)
        }
      end

      def position(noteable, args)
        position = args[:position]

        return unless position

        Gitlab::Diff::Position.new(position)
      end
    end
  end
end
