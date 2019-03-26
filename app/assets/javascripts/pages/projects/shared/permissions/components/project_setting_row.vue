<script>
import { GlPopover } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
    GlPopover,
  },
  props: {
    label: {
      type: String,
      required: false,
      default: null,
    },
    helpPath: {
      type: String,
      required: false,
      default: null,
    },
    helpText: {
      type: String,
      required: false,
      default: null,
    },
    helpTooltipText: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    popoverOptions() {
      const defaults = {
        placement: 'top',
      };

      return { ...defaults, content: this.helpTooltipText };
    },
  },
};
</script>

<template>
  <div class="project-feature-row">
    <label v-if="label" class="label-bold">
      {{ label }}
      <a v-if="helpPath" :href="helpPath" target="_blank">
        <i aria-hidden="true" data-hidden="true" class="fa fa-question-circle"> </i>
      </a>
      <template v-if="helpTooltipText">
        <icon :size="14" name="question" id="help-popup-trigger" />
        <gl-popover
          target="help-popup-trigger"
          boundary="viewport"
          placement="top"
          triggers="hover"
        >
          {{ helpTooltipText }}
        </gl-popover>
      </template>
    </label>
    <span v-if="helpText" class="form-text text-muted"> {{ helpText }} </span> <slot></slot>
  </div>
</template>
