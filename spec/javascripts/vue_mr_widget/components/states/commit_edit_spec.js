import { createLocalVue, shallowMount } from '@vue/test-utils';
import CommitEdit from '~/vue_merge_request_widget/components/states/commit_edit.vue';

const localVue = createLocalVue();
const testCommitMessage = 'Test commit message';
const testLabel = 'Test label';
const testInputId = 'test-input-id';

describe('Commits edit component', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(localVue.extend(CommitEdit), {
      localVue,
      sync: false,
      propsData: {
        value: testCommitMessage,
        label: testLabel,
        inputId: testInputId,
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

    expect(labelElement.text()).toBe(testLabel);
  });

  describe('textarea', () => {
    it('has a correct ID', () => {
      expect(findTextarea().attributes('id')).toBe(testInputId);
    });

    it('has a correct value', () => {
      expect(findTextarea().element.value).toBe(testCommitMessage);
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
