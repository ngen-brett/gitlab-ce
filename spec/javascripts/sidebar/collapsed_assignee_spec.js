import { shallowMount } from '@vue/test-utils';
import CollapsedAssignee from '~/sidebar/components/assignees/collapsed_assignee.vue';
import { userDataMock } from './mock_data';

describe('CollapsedAssignee assignee component', () => {
  let wrapper;
  const defaultProps = {
    user: userDataMock,
    index: 1,
    length: 6,
  };

  function createComponent(props = {}) {
    const propsData = {
      ...defaultProps,
      ...props,
    };

    wrapper = shallowMount(CollapsedAssignee, {
      propsData,
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  it('does not show assignee if shouldRenderCollapsedAssignee returns false', () => {
    createComponent();

    expect(wrapper.isEmpty()).toBe(true);
  });

  it('shows assignee if shouldRenderCollapsedAssignee returns true', () => {
    createComponent({
      index: 0,
    });

    expect(wrapper.isEmpty()).toBe(false);
  });
});
