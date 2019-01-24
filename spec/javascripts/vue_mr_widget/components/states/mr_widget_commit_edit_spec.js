import { createLocalVue, shallowMount } from '@vue/test-utils';
import CommitEdit from '~/vue_merge_request_widget/components/states/commit_edit.vue';

const localVue = createLocalVue();

describe('Commits edit component', () => {
  let wrapper;

  const createComponent = props => {
    wrapper = shallowMount(localVue.extend(CommitEdit), {
      localVue,
      sync: false,
      propsData: {
        isSquashEnabled: false,
        targetBranch: 'master',
        expanded: false,
        commitsCount: 5,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });
});
