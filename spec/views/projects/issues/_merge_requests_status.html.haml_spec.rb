# frozen_string_literal: true
require 'spec_helper'

describe 'projects/issues/_merge_requests_status.html.haml' do
  it 'shows date of status change in tooltip' do
    merge_request = create(:merge_request, created_at: 14.days.ago)

    render partial: 'projects/issues/merge_requests_status',
           locals: { merge_request: merge_request, css_class: '' }

    expect(rendered).to match(/Opened.*14 days ago/)
  end

  it 'shows only status in tooltip if date is not set' do
    merge_request = create(:merge_request, state: :closed)

    render partial: 'projects/issues/merge_requests_status',
           locals: { merge_request: merge_request, css_class: '' }

    expect(rendered).to match("Closed")
  end
end
