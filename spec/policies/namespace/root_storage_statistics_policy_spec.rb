# frozen_string_literal: true

require 'spec_helper'

describe Namespace::RootStorageStatisticsPolicy do
  using RSpec::Parameterized::TableSyntax

  describe '#rules' do
    let(:statistics) { create(:namespace_root_storage_statistics, namespace: namespace) }
    let(:user) { create(:user) }

    subject { Ability.allowed?(user, :read_statistics, statistics) }

    context 'when the namespace is not a group' do
      let(:owner) { create(:user) }
      let(:namespace) { owner.namespace }

      context 'when the user is not the owner' do
        it { is_expected.to be(false) }
      end

      context 'when the user is the owner' do
        let(:user) { owner }

        it { is_expected.to be(true) }
      end

      context 'when the user is anonymous' do
        let(:user) { nil }

        it { is_expected.to be(false) }
      end
    end

    context 'when the namespace is a group' do
      let(:external)   { create(:user, :external) }
      let(:guest)      { create(:user) }
      let(:reporter)   { create(:user) }
      let(:developer)  { create(:user) }
      let(:maintainer) { create(:user) }
      let(:owner)      { create(:user) }

      let(:users) do
        {
          unauthenticated: nil,
          non_member: create(:user),
          guest: guest,
          reporter: reporter,
          developer: developer,
          maintainer: maintainer,
          owner: owner
        }
      end

      where(:group_type, :user_type, :outcome) do
        [
          # Public group
          [:public, :unauthenticated, false],
          [:public, :non_member, false],
          [:public, :guest, false],
          [:public, :reporter, false],
          [:public, :developer, false],
          [:public, :maintainer, false],
          [:public, :owner, true],

          # Private group
          [:private, :unauthenticated, false],
          [:private, :non_member, false],
          [:private, :guest, false],
          [:private, :reporter, false],
          [:private, :developer, false],
          [:private, :maintainer, false],
          [:private, :owner, true],

          # Internal group
          [:internal, :unauthenticated, false],
          [:internal, :non_member, false],
          [:internal, :guest, false],
          [:internal, :reporter, false],
          [:internal, :developer, false],
          [:internal, :maintainer, false],
          [:internal, :owner, true]
        ]
      end

      with_them do
        let(:user) { users[user_type] }
        let(:group) { create(:group, visibility_level: Gitlab::VisibilityLevel.level_value(group_type.to_s)) }
        let(:namespace) { group }

        before do
          group.add_guest(guest)
          group.add_reporter(reporter)
          group.add_developer(developer)
          group.add_maintainer(maintainer)
          group.add_owner(owner)
        end

        it { is_expected.to eq(outcome) }

        context 'when the user is external' do
          let(:user) { external }

          before do
            unless [:unauthenticated, :non_member].include?(user_type)
              group.add_user(external, user_type)
            end
          end

          it { is_expected.to eq(outcome) }
        end
      end
    end
  end
end
