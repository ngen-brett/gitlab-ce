# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Pages do
  before do
    allow(described_class).to receive(:secret_path).and_return(Rails.root.join('tmp', 'tests', '.pages_shared_secret'))

    begin
      File.delete(described_class.secret_path)
    rescue Errno::ENOENT
    end

    described_class.write_secret
  end

  describe '.verify_api_request' do
    let(:payload) { { 'iss' => 'gitlab-pages' } }

    it 'returns false if fails to validate the JWT' do
      encoded_token = JWT.encode(payload, 'wrongsecret', 'HS256')
      headers = { described_class::INTERNAL_API_REQUEST_HEADER => encoded_token }

      expect(described_class.verify_api_request(headers)).to eq(false)
    end

    it 'returns the decoded JWT' do
      encoded_token = JWT.encode(payload, described_class.secret, 'HS256')
      headers = { described_class::INTERNAL_API_REQUEST_HEADER => encoded_token }

      expect(described_class.verify_api_request(headers)).to eq([{ "iss" => "gitlab-pages" }, { "alg" => "HS256" }])
    end
  end
end
