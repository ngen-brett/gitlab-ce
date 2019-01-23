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

  describe('when collapsed', () => {
    beforeEach(() => {
      createComponent();
    });

    it('has collapsed class', () => {
      const headerWrapper = wrapper.find('.mr-widget-commits-count');

      expect(headerWrapper.classes()).toContain('collapsed');
    });
  });

  describe('when expanded', () => {
    beforeEach(() => {
      createComponent({ expanded: true });
    });

    it('has no collapsed class', () => {
      const headerWrapper = wrapper.find('.mr-widget-commits-count');

      expect(headerWrapper.classes()).not.toContain('collapsed');
    });
  });
});
