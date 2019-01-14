import { shallowMount, createLocalVue } from '@vue/test-utils';
import MergeCommitDetailsComponent from '~/vue_merge_request_widget/components/states/merge_commit_details.vue';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';

describe('MRWidgetMergeCommitDetails', () => {
  let wrapper;

  const commit = {
    author: {
      avatar_url:
        'https://www.gravatar.com/avatar/79e8be0c27f341afc67c0ab9f9030d17?s=72&amp;d=identicon',
      id: '12345',
      name: 'Test Name',
      web_url: 'http://gitlab.com',
    },
    author_name: 'Commit Test Name',
    author_email: 'test@gitlab.com',
    authored_date: '2018-12-05',
    description_html: 'Test description!',
    avatar_url: 'https://www.gravatar.com/avatar123',
  };

  const factory = (options = {}) => {
    const localVue = createLocalVue();

    wrapper = shallowMount(localVue.extend(MergeCommitDetailsComponent), {
      localVue,
      sync: false,
      ...options,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('user avatar', () => {
    it('should be rendered', () => {
      factory({ propsData: { commit, value: 'Some value' } });
      const userAvatar = wrapper.find(UserAvatarLink);

      expect(userAvatar.exists()).toBeTruthy();
    });

    it('should have correct props', () => {
      factory({ propsData: { commit, value: 'Some value' } });
      const userAvatar = wrapper.find(UserAvatarLink);

      expect(userAvatar.props('linkHref')).toEqual(wrapper.vm.authorUrl);
      expect(userAvatar.props('imgSrc')).toEqual(wrapper.vm.authorAvatar);
      expect(userAvatar.props('imgAlt')).toEqual(wrapper.vm.authorName);
    });
  });

  describe('committer', () => {
    describe('author link', () => {
      it('should be rendered', () => {
        factory({ propsData: { commit, value: 'Some value' } });
        const authorLink = wrapper.find('.committer').find('a');

        expect(authorLink.exists()).toBeTruthy();
      });

      it('should have correct URL', () => {
        factory({ propsData: { commit, value: 'Some value' } });
        const authorLink = wrapper.find('.committer').find('a');

        expect(authorLink.attributes('href')).toEqual(wrapper.vm.authorUrl);
      });

      it('should have correct class', () => {
        factory({ propsData: { commit, value: 'Some value' } });
        const authorLink = wrapper.find('.committer').find('a');

        expect(authorLink.classes()).toContain('js-user-link');
      });

      it('should have correct data user id', () => {
        factory({ propsData: { commit, value: 'Some value' } });
        const authorLink = wrapper.find('.committer').find('a');

        expect(authorLink.attributes('data-user-id')).toEqual(wrapper.vm.authorId);
      });

      it('should have correct text', () => {
        factory({ propsData: { commit, value: 'Some value' } });
        const authorLink = wrapper.find('.committer').find('a');

        expect(authorLink.text()).toEqual(wrapper.vm.authorName);
      });
    });
  });
});
