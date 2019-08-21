# frozen_string_literal: true

RSpec::Matchers.define :be_http_url do |_|
  match do |actual|
    case URI.parse(actual)
    when URI::HTTP, URI::HTTPS
      true
    else
      false
    end
  rescue
    false
  end
end

# looks better when used like:
#   expect(thing).to receive(:method).with(a_valid_http_url)
RSpec::Matchers.alias_matcher :a_valid_http_url, :be_http_url
