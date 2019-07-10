# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Slug::Environment do
  describe '#generate' do
    {
      "staging-12345678901234567" => "staging-123456789-aaaaaa",
      "9-staging-123456789012345" => "env-9-staging-123-aaaaaa",
      "staging-1234567890123456"  => "staging-1234567890123456",
      "production"                => "production",
      "PRODUCTION"                => "production-aaaaaa",
      "review/1-foo"              => "review-1-foo-aaaaaa",
      "1-foo"                     => "env-1-foo-aaaaaa",
      "1/foo"                     => "env-1-foo-aaaaaa",
      "foo-"                      => "foo-aaaaaa",
      "foo--bar"                  => "foo-bar-aaaaaa",
      "foo**bar"                  => "foo-bar-aaaaaa",
      "*-foo"                     => "env-foo-aaaaaa",
      "staging-12345678-"         => "staging-12345678-aaaaaa",
      "staging-12345678-01234567" => "staging-12345678-aaaaaa"
    }.each do |name, matcher|
      before do
        allow(Digest::SHA2).to receive(:hexdigest).with(name).and_return('a' * 64)
      end

      it "returns a slug matching #{matcher}, given #{name}" do
        slug = described_class.new(name).generate

        expect(slug).to match(/\A#{matcher}\z/)
      end
    end
  end
end
