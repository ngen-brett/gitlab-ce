import { createLocalVue, shallowMount } from '@vue/test-utils';
import CommitsHeader from '~/vue_merge_request_widget/components/states/commits_header.vue';

const localVue = createLocalVue();

describe('Commits header component', () => {
  let wrapper;

  const createComponent = props => {
    wrapper = shallowMount(localVue.extend(CommitsHeader), {
      localVue,
      sync: false,
      propsData: {
        isSquashEnabled: false,
        targetBranch: 'master',
        expanded: false,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('component mounted', () => {
    createComponent();

    expect(true).toBeTruthy();
  });
});
