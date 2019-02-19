# frozen_string_literal: true

module QA
  module Page
    module Project
      module Commit
        class Show < Page::Base
          include Page::Component::DiffAndPatchDownload

          view 'app/views/projects/commit/_commit_box.html.haml' do
            element :download_button
            element :email_patches
            element :plain_diff
          end
        end
      end
    end
  end
end
