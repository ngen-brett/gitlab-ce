import { shallowMount } from '@vue/test-utils';
import UncollapsedSingleAssignee from '~/sidebar/components/assignees/uncollapsed_single_assignee.vue';
import { userDataMock } from './mock_data';

describe('Uncollapsed single assignee component', () => {
  let wrapper;
  const defaultProps = {
    user: userDataMock,
    rootPath: 'http://localhost:3000/',
  };

  function createComponent(props = {}) {
    const propsData = {
      ...defaultProps,
      ...props,
    };

    wrapper = shallowMount(UncollapsedSingleAssignee, {
      propsData,
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  it('user who can merge has "Can merge" in tooltip', () => {
    createComponent();

    expect(wrapper.element.dataset.title.includes('Can merge')).toBe(true);
  });

  it('user who cannot merge has "Cannot merge" in tooltip', () => {
    createComponent({
      user: {
        can_merge: false,
      },
    });

    expect(wrapper.element.dataset.title.includes('Cannot merge')).toBe(true);
  });

  it('has the root url present in the assigneeUrl method', () => {
    createComponent();
    const { rootPath } = wrapper.vm;

    expect(wrapper.element.href.includes(rootPath)).toEqual(true);
  });
});
