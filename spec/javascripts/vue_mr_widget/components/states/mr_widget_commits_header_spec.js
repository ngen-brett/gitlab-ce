import { createLocalVue, shallowMount } from '@vue/test-utils';
import CommitsHeader from '~/vue_merge_request_widget/components/states/commits_header.vue';
import Icon from '~/vue_shared/components/icon.vue';

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
        commitsCount: 5,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findHeaderWrapper = () => wrapper.find('.js-mr-widget-commits-count');
  const findIcon = () => wrapper.find(Icon);
  const findCommitsCountMessage = () => wrapper.find('.commits-count-message');
  const findTargetBranchMessage = () => wrapper.find('.label-branch');
  const findModifyButton = () => wrapper.find('button');

  describe('when collapsed', () => {
    it('has collapsed class', () => {
      createComponent();

      expect(findHeaderWrapper().classes()).toContain('collapsed');
    });

    it('has a chevron-right icon', () => {
      createComponent();

      expect(findIcon().props('name')).toBe('chevron-right');
    });

    describe('when squash is disabled', () => {
      beforeEach(() => {
        createComponent();
      });

      it('has commits count message showing correct amount of commits', () => {
        expect(findCommitsCountMessage().text()).toBe('5 commits');
      });

      it('has button with modify merge commit message', () => {
        expect(findModifyButton().text()).toBe('Modify merge commit');
      });
    });

    describe('when squash is enabled', () => {
      beforeEach(() => {
        createComponent({ isSquashEnabled: true });
      });

      it('has commits count message showing one commit when squash is enabled', () => {
        expect(findCommitsCountMessage().text()).toBe('1 commit');
      });

      it('has button with modify commit messages text', () => {
        expect(findModifyButton().text()).toBe('Modify commit messages');
      });
    });

    it('has correct target branch displayed', () => {
      createComponent();

      expect(findTargetBranchMessage().text()).toBe('master.');
    });
  });

  describe('when expanded', () => {
    beforeEach(() => {
      createComponent({ expanded: true });
    });

    it('has no collapsed class', () => {
      expect(findHeaderWrapper().classes()).not.toContain('collapsed');
    });

    it('has a chevron-down icon', () => {
      expect(findIcon().props('name')).toBe('chevron-down');
    });

    it('has a collapse text', () => {
      expect(findHeaderWrapper().text()).toBe('Collapse');
    });
  });

  it('should emit a toggleCommitsList event when clicked', () => {
    createComponent();
    findHeaderWrapper().trigger('click');

    expect(wrapper.emitted('toggleCommitsList')).toBeTruthy();
  });
});
