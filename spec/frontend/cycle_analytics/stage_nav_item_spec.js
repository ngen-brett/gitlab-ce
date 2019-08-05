import Vue from 'vue';
import { mount } from '@vue/test-utils';
import StageNavItem from '~/cycle_analytics/components/stage_nav_item.vue';

describe('StageNavItem component', () => {
  let wrapper = null;

  beforeEach(() => {
    wrapper = mount.createComponent(StageNavItem);
  });

  afterEach(() => {
    wrapper.destroy();
  });
});
