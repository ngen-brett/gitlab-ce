import { shallowMount } from '@vue/test-utils';
import { GlModal } from '@gitlab/ui';
import ConfirmRollbackModal from '~/environments/components/confirm_rollback_modal.vue';

describe('Confirm Rollback Modal Component', () => {
  let component;
  let modal;

  beforeEach(() => {
    component = shallowMount(ConfirmRollbackModal, {
      propsData: {
        environment: {
          name: 'test',
        },
        isLastDeployment: false,
        modalId: 'test',
      },
    });

    modal = component.find(GlModal);
  });

  it('should show "Rollback" when isLastDeployment is false', () => {
    component.setProps({ isLastDeployment: false });
    const expectedText = 'Are you sure you wish to rollback the environment to this version?';

    expect(modal.attributes('title')).toBe('Rollback to test?');
    expect(modal.attributes('ok-title')).toBe('Rollback');
    expect(modal.text()).toBe(expectedText);
  });

  it('should show "Re-deploy" when isLastDeployment is false', () => {
    component.setProps({ isLastDeployment: true });
    const expectedText = 'Are you sure you wish to re-deploy this environment?';

    expect(modal.attributes('title')).toBe('Re-deploy to test?');
    expect(modal.attributes('ok-title')).toBe('Re-deploy');
    expect(modal.text()).toBe(expectedText);
  });

  it('should emit the "rollback" event when "ok" is clicked', () => {
    modal.vm.$emit('ok');

    expect(component.emitted('rollback').length).toBe(1);
  });
});
