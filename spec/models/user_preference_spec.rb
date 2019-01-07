# frozen_string_literal: true

require 'spec_helper'

describe UserPreference do
  let(:user_preference) { create(:user_preference) }

  describe '#set_notes_filter' do
    let(:issuable) { build_stubbed(:issue) }

    shared_examples 'setting system notes' do
      it 'returns updated discussion filter' do
        filter_name =
          user_preference.set_notes_filter(filter, issuable)

        expect(filter_name).to eq(filter)
      end

      it 'updates discussion filter for issuable class' do
        user_preference.set_notes_filter(filter, issuable)

        expect(user_preference.reload.issue_notes_filter).to eq(filter)
      end
    end

    context 'when filter is set to all notes' do
      let(:filter) { described_class::NOTES_FILTERS[:all_notes] }

      it_behaves_like 'setting system notes'
    end

    context 'when filter is set to only comments' do
      let(:filter) { described_class::NOTES_FILTERS[:only_comments] }

      it_behaves_like 'setting system notes'
    end

    context 'when filter is set to only activity' do
      let(:filter) { described_class::NOTES_FILTERS[:only_activity] }

      it_behaves_like 'setting system notes'
    end

    context 'when notes_filter parameter is invalid' do
      let(:only_comments) { described_class::NOTES_FILTERS[:only_comments] }

      it 'returns the current notes filter' do
        user_preference.set_notes_filter(only_comments, issuable)

        expect(user_preference.set_notes_filter(9999, issuable)).to eq(only_comments)
      end
    end
  end

  describe 'sort_by preferences' do
    shared_examples_for 'a sort_by preference' do
      it 'validates that the sorting field is valid' do
        user_preference.update(attribute => 19)

        expect(user_preference).not_to be_valid
      end

      it 'allows nil sort fields' do
        user_preference.update(attribute => nil)

        expect(user_preference).to be_valid
      end

      context 'attribute_field' do
        let(:method) { :"#{attribute}_field" }

        it 'turns DB values into strings' do
          user_preference.update(attribute => 4)

          expect(user_preference.send(method)).to eq('updated_asc')
        end

        it 'passes nils through' do
          user_preference.update(attribute => nil)

          expect(user_preference.send(method)).to be_nil
        end
      end

      context 'attribute_field=' do
        let(:method) { :"#{attribute}_field=" }

        it 'turns strings into proper DB values' do
          user_preference.send(method, 'updated_asc')

          expect(user_preference[attribute]).to eq(4)
        end

        it 'sets DB column to nil if key is unknown' do
          user_preference.send(method, 'not_a_sort_column')

          expect(user_preference[attribute]).to be_nil
        end
      end
    end

    context 'merge_request_sort_by attribute' do
      let(:attribute) { :merge_request_sort_by }

      it_behaves_like 'a sort_by preference'
    end

    context 'issue_sort_by attribute' do
      let(:attribute) { :issue_sort_by }

      it_behaves_like 'a sort_by preference'
    end
  end
end
