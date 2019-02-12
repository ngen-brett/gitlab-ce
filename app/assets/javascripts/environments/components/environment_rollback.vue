<script>
/**
 * Renders Rollback or Re deploy button in environments table depending
 * of the provided property `isLastDeployment`.
 *
 * Makes a post request when the button is clicked.
 */
import { s__ } from '~/locale';
import { GlTooltipDirective, GlLoadingIcon, GlModalDirective } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import ConfirmRollbackModal from './confirm_rollback_modal.vue';
import eventHub from '../event_hub';

export default {
  components: {
    Icon,
    GlLoadingIcon,
    ConfirmRollbackModal,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    'gl-modal': GlModalDirective,
  },
  props: {
    retryUrl: {
      type: String,
      default: '',
    },

    isLastDeployment: {
      type: Boolean,
      default: true,
    },

    environment: {
      type: Object,
      default: () => ({}),
    },
  },
  data() {
    return {
      isLoading: false,
      modalId: 'confirm-rollback-modal',
    };
  },

  computed: {
    title() {
      return this.isLastDeployment
        ? s__('Environments|Re-deploy to environment')
        : s__('Environments|Rollback environment');
    },
  },

  methods: {
    onClick() {
      this.isLoading = true;

      eventHub.$emit('postAction', { endpoint: this.retryUrl });
    },
  },
};
</script>
<template>
  <div>
    <button
      v-gl-tooltip
      v-gl-modal="modalId"
      :disabled="isLoading"
      :title="title"
      type="button"
      class="btn d-none d-sm-none d-md-block"
    >
      <icon v-if="isLastDeployment" name="repeat" /> <icon v-else name="redo" />
      <gl-loading-icon v-if="isLoading" />
    </button>
    <confirm-rollback-modal
      :is-last-deployment="isLastDeployment"
      :environment="environment"
      :modal-id="modalId"
      @rollback="onClick"
    />
  </div>
</template>
