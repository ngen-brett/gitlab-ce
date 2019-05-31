# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespaceStorageStatistics, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :namespace }
  end
end
