# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe 'projects/settings/operations/show' do
  let(:project) { create(:project) }

  let!(:error_tracking_setting) do
    create(:error_tracking_setting, project: project)
  end

  before do
    assign :project, project
    assign :error_tracking_setting, error_tracking_setting
  end

  describe 'Operations > Error Tracking' do
    before do
      stub_feature_flags(error_tracking: true)
    end

    context 'Settings page ' do
      it 'renders the Operations Settings page' do
        render

        expect(rendered).to have_content _('Error Tracking')
        expect(rendered).to have_content _('To link Sentry to GitLab, enter your Sentry URL and Auth Token')
        expect(rendered).to have_content _('Active')
      end
    end
  end
end
