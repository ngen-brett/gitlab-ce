# frozen_string_literal: true

# These helpers allow you to manipulate with notes.
#
# Usage:
#   describe "..." do
#     include Spec::Support::Helpers::Features::NotesHelpers
#     ...
#
#     add_note("Hello world!")
#
module Spec
  module Support
    module Helpers
      module Features
        module NotesHelpers
          def add_note(text)
            perform_enqueued_jobs do
              page.within(".js-main-target-form") do
                fill_in("note[note]", with: text)
                find(".js-comment-submit-button").click
              end
            end
          end

          def edit_note(note_text_to_edit, new_note_text)
            perform_enqueued_jobs do
              page.within("#notes-list") do
                # Find note which contains the text to update
                comment_li_note = all("li.note.note-wrapper", text: note_text_to_edit).last

                # Click comments edit button
                comment_li_note.find(".note-action-button.js-note-edit.btn", match: :first).click

                # Update comment in textarea
                edit_form = comment_li_note.find("form.edit-note")
                edit_form.fill_in('note[note]', with: new_note_text)

                # Save the new comment
                edit_form.find('button.js-comment-button.js-vue-issue-save').click
              end
            end
          end

          def preview_note(text)
            page.within('.js-main-target-form') do
              filled_text = fill_in('note[note]', with: text)

              # Wait for quick action prompt to load and then dismiss it with ESC
              # because it may block the Preview button
              wait_for_requests
              filled_text.send_keys(:escape)

              click_on('Preview')

              yield if block_given?
            end
          end
        end
      end
    end
  end
end
