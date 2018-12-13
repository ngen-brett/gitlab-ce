# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe 'projects/settings/operations/show' do
  let(:project) { create(:project, :repository) }

  describe 'Operations > Error Tracking' do
    before do
      stub_feature_flags(error_tracking: true)
    end

    context 'Settings page ' do
      it 'renders the Operations Settings page' do
        render

        expect(rendered).to have_content ('Error Tracking')
        expect(rendered).to have_content ('To link Sentry to Gitlab, enter your Sentry URL and bearer token')
        expect(rendered).to have_content ('Active')
      end
    end
  end
end
