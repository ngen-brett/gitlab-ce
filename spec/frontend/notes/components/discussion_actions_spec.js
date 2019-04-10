import createStore from '~/notes/stores';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { discussionMock } from '../../../javascripts/notes/mock_data';
import DiscussionActions from '~/notes/components/discussion_actions.vue';
import ReplyPlaceholder from '~/notes/components/discussion_reply_placeholder.vue';
import ResolveDiscussionButton from '~/notes/components/discussion_resolve_button.vue';
import ResolveWithIssueButton from '~/notes/components/discussion_resolve_with_issue_button.vue';
import JumpToNextDiscussionButton from '~/notes/components/discussion_jump_to_next_button.vue';

const factory = ({ localVue, store }) =>
  shallowMount(DiscussionActions, {
    localVue,
    store,
    propsData: {
      discussion: discussionMock,
      isResolving: false,
      resolveButtonTitle: 'Resolve discussion',
      resolveWithIssuePath: '/some/issue/path',
      shouldShowJumpToNextDiscussion: true,
    },
  });

describe('DiscussionActions', () => {
  let wrapper;

  beforeEach(() => {
    const localVue = createLocalVue();
    const store = createStore();
    wrapper = factory({ localVue, store });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders reply placeholder, resolve discussion button, resolve with issue button and jump to next discussion button', () => {
    expect(wrapper.find(ReplyPlaceholder).exists()).toBe(true);
    expect(wrapper.find(ResolveDiscussionButton).exists()).toBe(true);
    expect(wrapper.find(ResolveWithIssueButton).exists()).toBe(true);
    expect(wrapper.find(JumpToNextDiscussionButton).exists()).toBe(true);
  });

  it('only renders reply placholder if disccusion is not resolvable', () => {
    const discussion = { ...discussionMock };
    discussion.resolvable = false;
    wrapper.setProps({
      discussion,
    });
    expect(wrapper.find(ReplyPlaceholder).exists()).toBe(true);
    expect(wrapper.find(ResolveDiscussionButton).exists()).toBe(false);
    expect(wrapper.find(ResolveWithIssueButton).exists()).toBe(false);
    expect(wrapper.find(JumpToNextDiscussionButton).exists()).toBe(false);
  });

  it('does not render resolve with issue button if resolveWithIssuePath is falsy', () => {
    wrapper.setProps({ resolveWithIssuePath: '' });
    expect(wrapper.find(ResolveWithIssueButton).exists()).toBe(false);
  });

  it('does not render jump to next discussion button if shouldShowJumpToNextDiscussion is false', () => {
    wrapper.setProps({ shouldShowJumpToNextDiscussion: false });
    expect(wrapper.find(JumpToNextDiscussionButton).exists()).toBe(false);
  });
});
