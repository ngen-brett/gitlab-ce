# frozen_string_literal: true

require 'spec_helper'

describe ProjectFetchStatistic do
  it { is_expected.to belong_to(:project) }
end
