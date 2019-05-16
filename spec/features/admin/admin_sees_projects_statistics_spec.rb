# frozen_string_literal: true

require 'spec_helper'

describe "Admin > Admin sees projects statistics" do
  let(:current_user) { create(:admin) }

  before do
    sign_in(current_user)

    project_with_statistics = create(:project, :repository)
    project_without_statistics = create(:project, :repository)  { |project| project.statistics.destroy }

    visit admin_projects_path
  end

  it "shows project statistics for projects that have them" do
    expect(page.all('.stats').map(&:text)).to contain_exactly("0 Bytes", "Unknown")
  end
end
