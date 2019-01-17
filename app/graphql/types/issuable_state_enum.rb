# frozen_string_literal: true

module Types
  class IssuableStateEnum < BaseEnum
    graphql_name 'IssuableState'
    description 'State of a GitLab issue'

    value('OPEN', value: 'opened')
    value('CLOSED', value: 'closed')
    value('REOPENED', value: 'reopened')
    value('MERGED', value: 'merged')
  end
end
