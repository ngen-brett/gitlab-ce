# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::UsageDataCounters::WikiPageCounter, :clean_gitlab_redis_shared_state do
  include_examples :usage_data_counter_page_event, :create
  include_examples :usage_data_counter_page_event, :update
  include_examples :usage_data_counter_page_event, :delete

  describe 'totals' do
    creations = 5
    edits = 3
    deletions = 2

    before do
      creations.times do
        described_class.count(:create)
      end
      edits.times do
        described_class.count(:update)
      end
      deletions.times do
        described_class.count(:delete)
      end
    end

    it 'can report all totals' do
      expect(described_class.totals).to include(
        wiki_pages_update: edits,
        wiki_pages_create: creations,
        wiki_pages_delete: deletions
      )
    end
  end

  describe 'unknown events' do
    error = described_class::UnknownEvent

    it 'cannot increment' do
      expect { described_class.count(:wibble) }.to raise_error error
    end

    it 'cannot read' do
      expect { described_class.read(:wibble) }.to raise_error error
    end
  end
end
