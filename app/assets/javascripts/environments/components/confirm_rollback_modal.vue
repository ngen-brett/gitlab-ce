<script>
/**
 * Render modal to confirm rollback/redeploy.
 */

import { GlModal } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';

export default {
  name: 'ConfirmRollbackModal',

  components: {
    GlModal,
  },

  props: {
    environment: {
      type: Object,
      required: true,
      default: () => ({}),
    },
    isLastDeployment: {
      type: Boolean,
      required: true,
      default: false,
    },
    modalId: {
      type: String,
      required: true,
      default: 'confirm-rollback-modal',
    },
  },

  computed: {
    modalTitle() {
      return sprintf(
        this.isLastDeployment
          ? s__('Environments|Re-deploy to %{name}?')
          : s__('Environments|Rollback to %{name}?'),
        {
          name: this.environment.name,
        },
      );
    },

    modalText() {
      return this.isLastDeployment
        ? s__('Environments|Are you sure you wish to re-deploy this environment?')
        : s__('Environments|Are you sure you wish to rollback the environment to this version?');
    },

    modalActionText() {
      return this.isLastDeployment ? s__('Environments|Re-deploy') : s__('Environments|Rollback');
    },
  },
  methods: {
    onOk() {
      this.$emit('rollback');
    },
  },
};
</script>

<template>
  <gl-modal
    :title="modalTitle"
    :modal-id="modalId"
    :ok-title="modalActionText"
    ok-variant="danger"
    @ok="onOk"
  >
    {{ modalText }}
  </gl-modal>
</template>
