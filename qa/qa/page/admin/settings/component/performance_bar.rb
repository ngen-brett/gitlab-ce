# frozen_string_literal: true

module QA
  module Page
    module Admin
      module Settings
        module Component
          class PerformanceBar < Page::Base
            view 'app/views/admin/application_settings/_performance_bar.html.haml' do
              element :enable_performance_bar_field
              element :save_changes_button
            end

            def enable_performance_bar
              click_element :enable_performance_bar_field
            end

            def save_settings
              click_element :save_changes_button
            end
          end
        end
      end
    end
  end
end
