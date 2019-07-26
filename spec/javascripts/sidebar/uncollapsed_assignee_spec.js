import { shallowMount } from '@vue/test-utils';
import UncollapsedAssignee from '~/sidebar/components/assignees/uncollapsed_assignee.vue';
import { userDataMock } from './mock_data';

describe('Uncollapsed assignee component', () => {
  let wrapper;
  const defaultProps = {
    user: userDataMock,
    index: 1,
    defaultRenderCount: 5,
    showLess: true,
    rootPath: 'http://localhost:3000/',
  };

  function createComponent(props = {}) {
    const propsData = {
      ...defaultProps,
      ...props,
    };

    wrapper = shallowMount(UncollapsedAssignee, {
      propsData,
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  it('user who can merge has "can merge" in tooltip', () => {
    createComponent();

    expect(wrapper.element.querySelector('.user-link').dataset.title.includes('can merge')).toBe(
      true,
    );
  });

  it('user who cannot merge has "cannot merge" in tooltip', () => {
    createComponent({
      user: {
        can_merge: false,
      },
    });

    expect(wrapper.element.querySelector('.user-link').dataset.title.includes('cannot merge')).toBe(
      true,
    );
  });

  it('shows assignee if it is less than the allowed displayed assignee amount', () => {
    createComponent({
      index: 6,
    });

    expect(wrapper.isEmpty()).toBe(true);
  });

  it('does not shows assignee if it is more than the allowed displayed assignee amount', () => {
    createComponent({
      index: 4,
    });

    expect(wrapper.isEmpty()).toBe(false);
  });

  it('has the root url present in the assigneeUrl method', () => {
    createComponent();
    const { rootPath } = wrapper.vm;

    expect(wrapper.element.querySelector('.user-link').href.includes(rootPath)).toEqual(true);
  });
});
