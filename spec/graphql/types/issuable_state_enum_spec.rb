# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['IssuableState'] do
  it { expect(described_class.graphql_name).to eq('IssuableState') }

  it 'exposes all the existing issuable states' do
    actual_states = Hash[described_class.values.map { |_, v| [v.name, v.value] }]
    expected_states = { 'OPEN' => 'opened', 'CLOSED' => 'closed', 'MERGED' => 'merged', 'REOPENED' => 'reopened' }

    expect(actual_states).to eq(expected_states)
  end
end
