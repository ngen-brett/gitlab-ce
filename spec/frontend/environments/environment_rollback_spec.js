import { shallowMount, mount, createLocalVue } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import eventHub from '~/environments/event_hub';
import rollbackComp from '~/environments/components/environment_rollback.vue';

describe('Rollback Component', () => {
  const retryUrl = 'https://gitlab.com/retry';
  const localVue = createLocalVue();
  let RollbackComponent;

  beforeEach(() => {
    RollbackComponent = localVue.extend(rollbackComp);
  });

  it('Should render Re-deploy label when isLastDeployment is true', () => {
    const component = mount(RollbackComponent, {
      propsData: {
        retryUrl,
        isLastDeployment: true,
        environment: {},
      },
    });

    expect(component.element).toHaveSpriteIcon('repeat');
  });

  it('Should render Rollback label when isLastDeployment is false', () => {
    const component = mount(RollbackComponent, {
      propsData: {
        retryUrl,
        isLastDeployment: false,
        environment: {},
      },
    });

    expect(component.element).toHaveSpriteIcon('redo');
  });

  it('should emit a "rollback" event on button click', () => {
    const eventHubSpy = jest.spyOn(eventHub, '$emit');
    const component = shallowMount(RollbackComponent, {
      propsData: {
        retryUrl,
        environment: {
          name: 'test',
        },
      },
    });
    const button = component.find(GlButton);

    button.vm.$emit('click');

    expect(eventHubSpy).toHaveBeenCalledWith('requestRollbackEnvironment', {
      retryUrl,
      isLastDeployment: true,
      name: 'test',
    });
  });
});
