import { createLocalVue, shallowMount } from '@vue/test-utils';
import CommitEdit from '~/vue_merge_request_widget/components/states/commit_edit.vue';

const localVue = createLocalVue();

describe('Commits edit component', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(localVue.extend(CommitEdit), {
      localVue,
      sync: false,
      propsData: {
        value: 'Test commit message',
        label: 'Test label',
        inputId: 'test-input-id',
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findTextarea = () => wrapper.find('.js-commit-message');

  it('has a correct label', () => {
    const labelElement = wrapper.find('.col-form-label');

    expect(labelElement.text()).toBe('Test label');
  });

  describe('textarea', () => {
    it('has a correct ID', () => {
      expect(findTextarea().attributes('id')).toBe('test-input-id');
    });

    it('has a correct value', () => {
      expect(findTextarea().element.value).toBe('Test commit message');
    });

    it('emits an input event and receives changed value', () => {
      const changedCommitMessage = 'Changed commit message';

      findTextarea().element.value = changedCommitMessage;
      findTextarea().trigger('input');

      expect(wrapper.emitted().input[0]).toEqual([changedCommitMessage]);
      expect(findTextarea().element.value).toBe(changedCommitMessage);
    });
  });
});
