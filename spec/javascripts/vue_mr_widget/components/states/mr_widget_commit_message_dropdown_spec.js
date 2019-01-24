import { createLocalVue, shallowMount } from '@vue/test-utils';
import CommitMessageDropdown from '~/vue_merge_request_widget/components/states/commit_message_dropdown.vue';

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
  const findDropdownElements = () => wrapper.findAll('.dropdown-commit');

  it('should not display a dropdown list by default', () => {
    expect(findDropdownWrapper().classes()).not.toContain('show');
  });

  it('should have 3 elements in dropdown list', () => {
    expect(findDropdownElements().length).toBe(3);
  });

  it('should have correct message for the first dropdown list element', () => {
    expect(
      findDropdownElements()
        .at(0)
        .text(),
    ).toBe('78d5b7 Commit 1');
  });

  it('should emit a commit title on selecting commit', () => {
    findDropdownElements()
      .at(0)
      .trigger('click');

    expect(wrapper.emitted().input[0]).toEqual(['Commit 1']);
  });
});
