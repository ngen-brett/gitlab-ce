import { shallowMount, createLocalVue } from '@vue/test-utils';
import MergeCommitDetailsComponent from '~/vue_merge_request_widget/components/states/merge_commit_details.vue';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { trimText } from 'spec/helpers/vue_component_helper';

const getUserAvatar = wrapper => wrapper.find(UserAvatarLink);
const getAuthorLink = wrapper => wrapper.find('.committer').find('a');
const getTimeAgoTooltip = wrapper => wrapper.find(TimeAgoTooltip);
const getToggleDescriptionButton = wrapper => wrapper.find('.text-expander');
const getCommitDescription = wrapper => wrapper.find('.commit-row-description');
const getEditMessageButton = wrapper => wrapper.find('.js-modify-commit-message-button');
const getMessageEditor = wrapper => wrapper.find('.commit-message-editor');

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
    author_gravatar_url: 'https://www.gravatar.com/avatar123',
  };

  const value = 'Some value';
  const localVue = createLocalVue();

  const factory = (props = { commit, value }) => {
    wrapper = shallowMount(localVue.extend(MergeCommitDetailsComponent), {
      localVue,
      sync: false,
      propsData: {
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('computed', () => {
    describe('author', () => {
      it('should return commit author if present', () => {
        factory();

        expect(wrapper.vm.author).toEqual(commit.author);
      });

      it('should return an empty object if no author', () => {
        const customCommit = { ...commit, author: null };
        factory({ commit: customCommit, value });

        expect(wrapper.vm.author).toEqual({});
      });
    });

    describe('author name', () => {
      it('should return author name if present', () => {
        factory();

        expect(wrapper.vm.authorName).toEqual(commit.author.name);
      });

      it('should return a commit author_name if no author is present', () => {
        const customCommit = { ...commit, author: null };
        factory({ commit: customCommit, value });

        expect(wrapper.vm.authorName).toEqual(commit.author_name);
      });
    });

    describe('author class', () => {
      it('should return correct class if author name is present', () => {
        factory();

        expect(wrapper.vm.authorClass).toEqual('js-user-link');
      });

      it('should return an empty string if no author name is present', () => {
        const customCommit = { ...commit, author: null };
        factory({ commit: customCommit, value });

        expect(wrapper.vm.authorClass).toEqual('');
      });
    });

    describe('author id', () => {
      it('should return author id if present', () => {
        factory();

        expect(wrapper.vm.authorId).toEqual(commit.author.id);
      });

      it('should return an empty string if no author id is present', () => {
        const customCommit = { ...commit, author: null };
        factory({ commit: customCommit, value });

        expect(wrapper.vm.authorId).toEqual('');
      });
    });

    describe('author url', () => {
      it('should return author url if present', () => {
        factory();

        expect(wrapper.vm.authorUrl).toEqual(commit.author.web_url);
      });

      it('should return a mailto link if no author url is present', () => {
        const customCommit = { ...commit, author: null };
        factory({ commit: customCommit, value });

        expect(wrapper.vm.authorUrl).toEqual(`mailto:${commit.author_email}`);
      });
    });

    describe('author avatar', () => {
      it('should return author avatar url if present', () => {
        factory();

        expect(wrapper.vm.authorAvatar).toEqual(commit.author.avatar_url);
      });

      it('should return a commit gravatar link no author avatar url is present', () => {
        const customCommit = { ...commit, author: null };
        factory({ commit: customCommit, value });

        expect(wrapper.vm.authorAvatar).toEqual(commit.author_gravatar_url);
      });
    });
  });

  describe('user avatar', () => {
    it('should be rendered', () => {
      factory();

      expect(getUserAvatar(wrapper).exists()).toBeTruthy();
    });

    it('should have correct props', () => {
      factory();
      const userAvatar = getUserAvatar(wrapper);

      expect(userAvatar.props('linkHref')).toEqual(wrapper.vm.authorUrl);
      expect(userAvatar.props('imgSrc')).toEqual(wrapper.vm.authorAvatar);
      expect(userAvatar.props('imgAlt')).toEqual(wrapper.vm.authorName);
    });
  });

  describe('committer', () => {
    describe('author link', () => {
      it('should be rendered', () => {
        factory();

        expect(getAuthorLink(wrapper).exists()).toBeTruthy();
      });

      it('should have correct URL', () => {
        factory();

        expect(getAuthorLink(wrapper).attributes('href')).toEqual(wrapper.vm.authorUrl);
      });

      it('should have js-user-link class if authorClass is present', () => {
        factory();

        expect(getAuthorLink(wrapper).classes()).toContain('js-user-link');
      });

      it('should not have js-user-link if no authorClass is present', () => {
        const customCommit = { ...commit, author: null };
        factory({ commit: customCommit, value });

        expect(getAuthorLink(wrapper).classes()).not.toContain('js-user-link');
      });

      it('should have correct data user id', () => {
        factory();

        expect(getAuthorLink(wrapper).attributes('data-user-id')).toEqual(wrapper.vm.authorId);
      });

      it('should have correct text', () => {
        factory();

        expect(getAuthorLink(wrapper).text()).toEqual(wrapper.vm.authorName);
      });
    });

    describe('if commit is squash commit', () => {
      beforeEach(() => {
        factory({ commit, value, squash: true });
      });

      it('timeago tooltip should be rendered', () => {
        expect(getTimeAgoTooltip(wrapper).exists()).toBeTruthy();
      });

      it('timeago tooltip should receive a correct time prop', () => {
        expect(getTimeAgoTooltip(wrapper).props('time')).toEqual(commit.authored_date);
      });
    });

    describe('if commit is merge commit', () => {
      it('timeago tooltip should not be rendered', () => {
        factory();

        expect(getTimeAgoTooltip(wrapper).exists()).toBeFalsy();
      });
    });
  });

  it('should contain a correct commit message', () => {
    factory();
    const commitMessage = wrapper.find('.commit-row-message');

    expect(commitMessage.text()).toEqual(value);
  });

  describe('without commit description', () => {
    beforeEach(() => {
      const customCommit = { ...commit, description_html: null };
      factory({ commit: customCommit, value });
    });

    it('should not have a  toggle button if commit has no description', () => {
      expect(getToggleDescriptionButton(wrapper).exists()).toBeFalsy();
    });

    it('should not be rendered if commit has no description', () => {
      expect(getCommitDescription(wrapper).exists()).toBeFalsy();
    });
  });

  describe('with commit description', () => {
    beforeEach(() => {
      factory();
    });

    it('should have a  toggle button if commit has a description', () => {
      expect(getToggleDescriptionButton(wrapper).exists()).toBeTruthy();
    });

    it('should be rendered if commit has a description', () => {
      expect(getCommitDescription(wrapper).exists()).toBeTruthy();
    });

    it('should contain correct description test', () => {
      const expected = commit.description_html.replace(/&#x000A;/g, '');

      expect(getCommitDescription(wrapper).text()).toEqual(trimText(expected));
    });

    it('should hide a description by default', () => {
      expect(getCommitDescription(wrapper).element.style.display).toEqual('none');
    });

    it('should toggle a description after toggle button is clicked', done => {
      getToggleDescriptionButton(wrapper).trigger('click');

      wrapper.vm.$nextTick(() => {
        expect(getCommitDescription(wrapper).element.style.display).toEqual('block');
        done();
      });
    });
  });

  describe('commit actions', () => {
    describe('with fast-forward only enabled', () => {
      beforeEach(() => {
        factory({ commit, value, ffOnlyEnabled: true });
      });

      it('should fast-forward message', () => {
        const ffMessage = wrapper.find('.js-fast-forward-message');

        expect(ffMessage.exists()).toBeTruthy();
      });

      it('should not render edit message button', () => {
        expect(getEditMessageButton(wrapper).exists()).toBeFalsy();
      });
    });

    describe('with fast-forward only disabled', () => {
      beforeEach(() => {
        factory();
      });

      it('should render edit message button', () => {
        expect(getEditMessageButton(wrapper).exists()).toBeTruthy();
      });

      it('should not render message editor by default', () => {
        expect(getMessageEditor(wrapper).exists()).toBeFalsy();
      });

      it('should toggle message editor after edit button click', done => {
        getEditMessageButton(wrapper).trigger('click');

        wrapper.vm.$nextTick(() => {
          expect(getMessageEditor(wrapper).exists()).toBeTruthy();
          done();
        });
      });
    });
  });
});
