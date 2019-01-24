import { createLocalVue, shallowMount } from '@vue/test-utils';
import CommitMessageDropdown from '~/vue_merge_request_widget/components/states/commit_message_dropdown.vue';
import Icon from '~/vue_shared/components/icon.vue';

const localVue = createLocalVue();
const commits = [
  {
    title: 'Commit 1',
    sha: '78d5b7',
    message: 'Update test.txt',
  },
  {
    title: 'Commit 2',
    sha: '34cbe28b',
    message: 'Fixed test',
  },
  {
    title: 'Commit 3',
    sha: 'fa42932a',
    message: 'Added changelog',
  },
];

describe('Commits message dropdown component', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(localVue.extend(CommitMessageDropdown), {
      localVue,
      sync: false,
      propsData: {
        commits,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findDropdownWrapper = () => wrapper.find('.dropdown-menu');

  it('should not render a dropdown list by default', () => {
    createComponent();

    expect(findDropdownWrapper().classes()).not.toContain('show');
  });
});
