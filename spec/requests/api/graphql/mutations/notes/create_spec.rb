# frozen_string_literal: true

require 'spec_helper'

describe 'Adding a Note' do
  include GraphqlHelpers

  set(:current_user) { create(:user) }
  let(:noteable) { create(:merge_request, source_project: project, target_project: project) }
  let(:project) { create(:project, :repository) }
  let(:position) { nil }
  let(:body) { 'Body text' }
  let(:type) { 'Note' }
  let(:mutation) do
    variables = {
      noteable_id: GitlabSchema.id_from_object(noteable).to_s,
      body: body,
      type: type,
      position: position
    }

    graphql_mutation(:create_note, variables)
  end

  def mutation_response
    graphql_mutation_response(:create_note)
  end

  shared_examples 'a mutation that does not create a Note' do
    it do
      expect do
        post_graphql_mutation(mutation, current_user: current_user)
      end.not_to change { Note.count }
    end
  end

  shared_examples 'a mutation that creates a Note' do
    it do
      expect do
        post_graphql_mutation(mutation, current_user: current_user)
      end.to change { Note.count }.by(1)
    end
  end

  context 'when the user does not have permission' do
    it_behaves_like 'a mutation that does not create a Note'

    it_behaves_like 'a mutation that returns top-level errors',
                    errors: ['The resource that you are attempting to access does not exist or you don\'t have permission to perform this action']
  end

  context 'when the user has permission' do
    before do
      project.add_developer(current_user)
    end

    it_behaves_like 'a mutation that creates a Note'

    it 'returns the note' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(mutation_response['note']['body']).to eq(body)
    end

    context 'when there were active record validation errors' do
      before do
        expect_next_instance_of(Note) do |note|
          expect(note).to receive(:valid?).at_least(:once).and_return(false)
          expect(note).to receive_message_chain(
            :errors,
            :full_messages
          ).and_return(['Error 1', 'Error 2'])
        end
      end

      it_behaves_like 'a mutation that does not create a Note'

      it_behaves_like 'a mutation that returns errors in the response', errors: ['Error 1', 'Error 2']

      it 'returns an empty Note' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(mutation_response).to have_key('note')
        expect(mutation_response['note']).to be_nil
      end
    end

    context 'when the given noteable is not a Noteable' do
      let(:noteable) { create(:label, project: project) }

      it_behaves_like 'a mutation that does not create a Note'

      it_behaves_like 'a mutation that returns top-level errors',
                      errors: ['Cannot add notes to this resource']
    end

    describe 'creating `DiffNote`s' do
      let(:type) { 'DiffNote' }

      def mutation_position_response
        mutation_response['note']['position']
      end

      describe 'creating `DiffNote`s on text diffs' do
        let(:position) do
          Gitlab::Diff::Position.new(
            old_path: 'files/ruby/popen.rb',
            new_path: 'files/ruby/popen.rb',
            old_line: nil,
            new_line: 14,
            position_type: 'text',
            diff_refs: noteable.diff_refs
          ).to_h
        end

        it_behaves_like 'a mutation that creates a Note'

        it 'returns a Note with the correct position' do
          post_graphql_mutation(mutation, current_user: current_user)

          expect(mutation_position_response['positionType']).to eq('text')
          expect(mutation_position_response['filePath']).to eq('files/ruby/popen.rb')
          expect(mutation_position_response['oldPath']).to eq('files/ruby/popen.rb')
          expect(mutation_position_response['newPath']).to eq('files/ruby/popen.rb')
          expect(mutation_position_response['newLine']).to eq(14)
        end
      end

      describe 'creating `DiffNote`s on image diffs' do
        let(:position) do
          Gitlab::Diff::Position.new(
            old_path: 'files/images/any_image.png',
            new_path: 'files/images/any_image.png',
            width: 100,
            height: 200,
            x: 1,
            y: 2,
            diff_refs: noteable.diff_refs,
            position_type: 'image'
          ).to_h
        end

        it_behaves_like 'a mutation that creates a Note'

        it 'returns a Note with the correct position' do
          post_graphql_mutation(mutation, current_user: current_user)

          expect(mutation_position_response['positionType']).to eq('image')
          expect(mutation_position_response['width']).to eq(100)
          expect(mutation_position_response['height']).to eq(200)
          expect(mutation_position_response['x']).to eq(1)
          expect(mutation_position_response['y']).to eq(2)
        end
      end
    end
  end
end
