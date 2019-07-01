# frozen_string_literal: true

module Types
  module Notes
    class NoteTypeEnum < BaseEnum
      graphql_name 'NoteType'
      description 'Type of note'

      value 'Note'
      value 'DiffNote'
    end
  end
end
