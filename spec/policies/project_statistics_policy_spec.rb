require 'spec_helper'

describe ProjectStatisticsPolicy do
  describe '#rules' do
    let(:user) { create(:user) }
    let(:project) { create(:project, :public) }
    let(:project_statistics) { create(:project_statistics, project: project) }
    let(:policy) { described_class.new(user, project_statistics) }

    shared_examples 'require reporter level' do
      it 'disallow guest' do
        project.add_guest(user)

        expect(policy).to be_disallowed(:read_statistics)
      end

      it 'allow reporter' do
        project.add_reporter(user)

        expect(policy).to be_allowed(:read_statistics)
      end

      context 'without a user' do
        let(:user) { nil }

        it 'disallow reading statistics' do
          expect(policy).to be_disallowed(:read_statistics)
        end
      end
    end

    include_examples 'require reporter level'

    context 'when the project is private' do
      let(:project) { create(:project, :private) }

      include_examples 'require reporter level'
    end

    context 'when the project is internal' do
      let(:project) { create(:project, :internal) }

      include_examples 'require reporter level'
    end
  end
end
