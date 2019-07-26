import { shallowMount } from '@vue/test-utils';
import AssigneeAvatar from '~/sidebar/components/assignees/assignee_avatar.vue';
import { userDataMock } from './mock_data';

describe('AssigneeAvatar', () => {
  let wrapper;
  const defaultProps = {
    user: userDataMock,
    imgSize: 24,
  };

  function createComponent(props = {}) {
    const propsData = {
      ...defaultProps,
      ...props,
    };

    wrapper = shallowMount(AssigneeAvatar, {
      propsData,
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  it('does not show warning icon if assignee can merge', () => {
    createComponent();

    expect(wrapper.element.querySelector('.merge-icon')).toBeNull();
  });

  it('shows warning icon if assignee cannot merge', () => {
    createComponent({
      user: {
        can_merge: false,
      },
    });

    expect(wrapper.element.querySelector('.merge-icon')).not.toBeNull();
  });
});
