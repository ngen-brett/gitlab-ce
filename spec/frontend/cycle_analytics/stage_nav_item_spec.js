import { mount, shallowMount } from '@vue/test-utils';
import StageNavItem from '~/cycle_analytics/components/stage_nav_item.vue';

describe('StageNavItem', () => {
  let wrapper = null;
  const title = 'Cool stage';
  const value = '1 day';

  function createComponent(props, shallow = true) {
    const func = shallow ? shallowMount : mount;
    return func(StageNavItem, {
      propsData: {
        isActive: false,
        isUserAllowed: false,
        title,
        value,
        ...props,
      },
    });
  }

  function hasStageName() {
    const stageName = wrapper.find('.stage-name');
    expect(stageName.exists()).toBe(true);
    expect(stageName.text()).toEqual(title);
  }

  describe('User has access', () => {
    beforeEach(() => {
      wrapper = createComponent({ isUserAllowed: true });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('renders stage name', () => {
      hasStageName();
    });

    describe('with a value', () => {
      beforeEach(() => {
        wrapper = createComponent({ isUserAllowed: true });
      });

      afterEach(() => {
        wrapper.destroy();
      });
      it('renders the value', () => {
        expect(wrapper.find('.stage-empty').exists()).toBe(false);
        expect(wrapper.find('.not-available').exists()).toBe(false);
        expect(wrapper.find('span').text()).toEqual(value);
      });
    });

    describe('without a value', () => {
      beforeEach(() => {
        wrapper = createComponent({ isUserAllowed: true, value: null });
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it('has the stage-empty class', () => {
        expect(wrapper.find('.stage-empty').exists()).toBe(true);
      });

      it('renders Not enough data', () => {
        expect(wrapper.find('span').text()).toEqual('Not enough data');
      });
    });
  });

  describe('is active', () => {
    beforeEach(() => {
      wrapper = createComponent({ isActive: true }, false);
    });

    afterEach(() => {
      wrapper.destroy();
    });
    it('has the active class', () => {
      expect(wrapper.find('.stage-nav-item').classes('active')).toBe(true);
    });
  });

  describe('is not active', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
    });
    it('emits the `select` event when clicked', () => {
      expect(wrapper.emitted().select).toBeUndefined();
      wrapper.trigger('click');
      expect(wrapper.emitted().select.length).toBe(1);
    });
  });

  describe('User does not have access', () => {
    beforeEach(() => {
      wrapper = createComponent({ isUserAllowed: false });
    });

    afterEach(() => {
      wrapper.destroy();
    });
    it('renders stage name', () => {
      hasStageName();
    });

    it('has class not-available', () => {
      expect(wrapper.find('.stage-empty').exists()).toBe(false);
      expect(wrapper.find('.not-available').exists()).toBe(true);
    });

    it('renders Not available', () => {
      expect(wrapper.find('.not-available').text()).toBe('Not available');
    });
  });
});
