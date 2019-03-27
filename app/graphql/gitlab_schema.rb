# frozen_string_literal: true

class GitlabSchema < GraphQL::Schema
  use BatchLoader::GraphQL
  use Gitlab::Graphql::Authorize
  use Gitlab::Graphql::Present
  use Gitlab::Graphql::Connections

  query_analyzer Gitlab::Graphql::QueryAnalyzers::LogQueryComplexity.analyzer

  query(Types::QueryType)

  default_max_page_size 100

  # starting with a limit of 75.  A complex ProjectType query can easily
  # reach 45
  max_complexity 75

  mutation(Types::MutationType)
end
