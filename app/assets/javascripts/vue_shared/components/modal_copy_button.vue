<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { sprintf, __ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import Clipboard from 'clipboard';

export default {
  components: {
    GlButton,
    Icon,
  },

  directives: {
    GlTooltip: GlTooltipDirective,
  },

  props: {
    text: {
      type: String,
      required: false,
      default: '',
    },
    container: {
      type: String,
      required: false,
      default: '',
    },
    modalId: {
      type: String,
      required: false,
      default: '',
    },
    target: {
      type: String,
      required: false,
      default: '',
    },
    title: {
      type: String,
      required: true,
    },
    tooltipPlacement: {
      type: String,
      required: false,
      default: 'top',
    },
    tooltipContainer: {
      type: String,
      required: false,
      default: null,
    },
  },

  data() {
    return {
      copyTitle: '',
    };
  },

  computed: {
    tooltipTitle() {
      return this.copyTitle || this.title;
    },
  },

  mounted() {
    setTimeout(() => {
      const options = {};
      if (this.text) {
        options.text = () => this.text;
      }
      this.clipboard = new Clipboard(this.$el, {
        ...options,
        container:
          document.getElementById(`${this.modalId}___BV_modal_body_`) ||
          document.getElementById(this.container) ||
          document.body,
      });
      this.clipboard.on('success', e => {
        this.$emit('success', e);
        this.copyTitle = 'Copied';
        // Clear the selection and blur the trigger so it loses its border
        e.clearSelection();
      });
      this.clipboard.on('error', e => this.$emit('error', e));
    });
  },

  destroyed() {
    if (this.clipboard) {
      this.clipboard.destroy();
    }
  },

  methods: {
    onLeave() {
      this.copyTitle = this.title;
    },
  },
};
</script>
<template>
  <gl-button
    v-gl-tooltip="{ placement: tooltipPlacement, container: tooltipContainer }"
    :data-clipboard-target="target"
    :title="tooltipTitle"
  >
    <slot>
      <Icon name="duplicate" />
    </slot>
  </gl-button>
</template>
