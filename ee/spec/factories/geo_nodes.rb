FactoryBot.define do
  factory :geo_node do
    # Start at a number higher than the current port to avoid the GeoNode
    # "lock out" validation
    sequence(:url, Gitlab.config.gitlab.port + 1) do |port|
      uri = URI.parse("http://#{Gitlab.config.gitlab.host}:#{Gitlab.config.gitlab.relative_url_root}")
      uri.port = port
      uri.path += '/' unless uri.path.end_with?('/')

      uri.to_s
    end

    primary false

    trait :primary do
      primary true
      minimum_reverification_interval 7

      url do
        uri = URI.parse("http://#{Gitlab.config.gitlab.host}:#{Gitlab.config.gitlab.relative_url_root}")
        uri.port = Gitlab.config.gitlab.port
        uri.path += '/' unless uri.path.end_with?('/')

        uri.to_s
      end
    end
  end
end
