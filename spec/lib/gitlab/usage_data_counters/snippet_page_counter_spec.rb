# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::UsageDataCounters::SnippetPageCounter, :clean_gitlab_redis_shared_state do
  include_examples :usage_data_counter_page_event, :create
  include_examples :usage_data_counter_page_event, :update
  include_examples :usage_data_counter_page_event, :comment
end
