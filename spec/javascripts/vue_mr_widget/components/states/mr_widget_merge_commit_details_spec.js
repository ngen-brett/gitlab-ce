import { shallowMount, createLocalVue } from '@vue/test-utils';
import MergeCommitDetailsComponent from '~/vue_merge_request_widget/components/states/merge_commit_details.vue';

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
      ...options,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('should mount tests fine', () => {
    factory({ propsData: { commit, value: 'Some value' } });

    expect(1).toEqual(1);
  });
});
