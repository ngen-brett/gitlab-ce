# frozen_string_literal: true

require 'spec_helper'

describe Projects::StarrersController do
  let(:user_1) { create(:user, name: 'John') }
  let(:user_2) { create(:user, name: 'Mike') }
  let(:private_user) { create(:user, name: 'Mary', private_profile: true) }
  let(:admin) { create(:user, admin: true) }
  let(:project) { create(:project, :public) }

  before do
    user_1.toggle_star(project)
    user_2.toggle_star(project)
    private_user.toggle_star(project)
  end

  describe 'GET index' do
    def get_starrers(search: nil)
      get :index, params: { namespace_id: project.namespace, project_id: project, search: search }
    end

    def user_ids
      assigns[:starrers].map { |s| s['user_id'] }
    end

    context 'when project is public' do
      before do
        project.update_attribute(:visibility_level, Project::PUBLIC)
      end

      context 'when no user is logged in' do
        it 'only public starrers are visible' do
          get_starrers

          expect(user_ids).to contain_exactly(user_1.id, user_2.id)
        end

        it 'starrers counters are correct' do
          get_starrers

          expect(assigns[:total_count]).to eq(3)
          expect(assigns[:public_count]).to eq(2)
          expect(assigns[:private_count]).to eq(1)
        end

        context 'searching' do
          it 'only public starrers are visible' do
            get_starrers(search: 'Mike')

            expect(user_ids).to contain_exactly(user_2.id)
          end

          it 'starrers counters are correct' do
            get_starrers(search: 'Mike')

            expect(assigns[:total_count]).to eq(3)
            expect(assigns[:public_count]).to eq(2)
            expect(assigns[:private_count]).to eq(1)
          end
        end
      end

      context 'when private user is logged in' do
        before do
          sign_in(private_user)
        end

        it 'their star is also visible' do
          get_starrers

          expect(user_ids).to contain_exactly(user_1.id, user_2.id, private_user.id)
        end

        it 'starrers counters are correct' do
          get_starrers

          expect(assigns[:total_count]).to eq(3)
          expect(assigns[:public_count]).to eq(2)
          expect(assigns[:private_count]).to eq(1)
        end

        context 'searching' do
          it 'only public starrers are visible' do
            get_starrers(search: 'Mike')

            expect(user_ids).to contain_exactly(user_2.id)
          end

          it 'starrers counters are correct' do
            get_starrers(search: 'Mike')

            expect(assigns[:total_count]).to eq(3)
            expect(assigns[:public_count]).to eq(2)
            expect(assigns[:private_count]).to eq(1)
          end
        end
      end

      context 'when admin is logged in' do
        before do
          sign_in(admin)
        end

        it 'all starrers are visible' do
          get_starrers

          expect(user_ids).to include(user_1.id, user_2.id, private_user.id)
        end

        it 'starrers counters are correct' do
          get_starrers

          expect(assigns[:total_count]).to eq(3)
          expect(assigns[:public_count]).to eq(2)
          expect(assigns[:private_count]).to eq(1)
        end

        context 'searching' do
          it 'only public starrers are visible' do
            get_starrers(search: 'Mike')

            expect(user_ids).to contain_exactly(user_2.id)
          end

          it 'starrers counters are correct' do
            get_starrers(search: 'Mike')

            expect(assigns[:total_count]).to eq(3)
            expect(assigns[:public_count]).to eq(2)
            expect(assigns[:private_count]).to eq(1)
          end
        end
      end
    end

    context 'when project is private' do
      before do
        project.update(visibility_level: Project::PRIVATE)
      end

      it 'starrers are not visible for non logged in users' do
        get_starrers

        expect(assigns[:starrers]).to be_blank
      end

      context 'when user is logged in' do
        before do
          sign_in(project.creator)
        end

        it 'only public starrers are visible' do
          get_starrers

          expect(user_ids).to contain_exactly(user_1.id, user_2.id)
        end

        it 'starrers counters are correct' do
          get_starrers

          expect(assigns[:total_count]).to eq(3)
          expect(assigns[:public_count]).to eq(2)
          expect(assigns[:private_count]).to eq(1)
        end
      end
    end
  end
end
