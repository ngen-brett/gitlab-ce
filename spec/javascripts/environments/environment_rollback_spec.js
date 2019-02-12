import Vue from 'vue';
import { shallowMount } from '@vue/test-utils';
import eventHub from '~/environments/event_hub';
import rollbackComp from '~/environments/components/environment_rollback.vue';
import ConfirmRollbackModal from '~/environments/components/confirm_rollback_modal.vue';

describe('Rollback Component', () => {
  const retryURL = 'https://gitlab.com/retry';
  let RollbackComponent;

  beforeEach(() => {
    RollbackComponent = Vue.extend(rollbackComp);
  });

  it('Should render Re-deploy label when isLastDeployment is true', () => {
    const component = new RollbackComponent({
      el: document.querySelector('.test-dom-element'),
      propsData: {
        retryUrl: retryURL,
        isLastDeployment: true,
      },
    }).$mount();

    expect(component.$el).toHaveSpriteIcon('repeat');
  });

  it('Should render Rollback label when isLastDeployment is false', () => {
    const component = new RollbackComponent({
      el: document.querySelector('.test-dom-element'),
      propsData: {
        retryUrl: retryURL,
        isLastDeployment: false,
      },
    }).$mount();

    expect(component.$el).toHaveSpriteIcon('redo');
  });

  it('should send retry event if "rollback" is received from modal', () => {
    const eventHubSpy = spyOn(eventHub, '$emit');
    const component = shallowMount(RollbackComponent, {
      propsData: {
        retryUrl: retryURL,
      },
    });
    const modal = component.find(ConfirmRollbackModal);

    modal.vm.$emit('rollback');

    expect(eventHubSpy).toHaveBeenCalledWith('postAction', { endpoint: retryURL });
  });
});
