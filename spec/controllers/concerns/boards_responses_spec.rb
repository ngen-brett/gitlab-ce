# frozen_string_literal: true

require 'spec_helper'

describe BoardsResponses do
  let(:controller_class) do
    Class.new do
      include BoardsResponses
    end
  end

  subject(:controller) { controller_class.new }

  describe '#serialize_as_json' do
    let!(:board) { create(:board) }

    context 'with milestone' do
      let(:milestone) { create(:milestone) }

      before do
        board.update_attribute(:milestone_id, milestone.id)
      end

      it 'serializes properly' do
        expected = { id: board.id }

        expect(subject.serialize_as_json(board).to_h).to include(expected)
      end
    end

    context 'without milestone' do
      it 'serializes properly' do
        expected = { id: board.id }

        expect(subject.serialize_as_json(board).to_h).to include(expected)
      end
    end
  end
end
