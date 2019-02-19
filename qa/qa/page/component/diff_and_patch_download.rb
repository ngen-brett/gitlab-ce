# frozen_string_literal: true

module QA
  module Page
    module Component
      module DiffAndPatchDownload
        def select_email_patches
          click_element :download_button
          click_element :email_patches
        end

        def select_plain_diff
          click_element :download_button
          click_element :plain_diff
        end
      end
    end
  end
end
