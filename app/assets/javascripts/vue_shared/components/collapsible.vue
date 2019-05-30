<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  name: 'Collapsible',
  components: {
    Icon,
    GlButton,
  },
  data() {
    return {
      expanded: true,
    };
  },
  methods: {
    toggle() {
      this.expanded = !this.expanded;
    },
  },
  computed: {
    collapseIcon() {
      return this.expanded ? 'chevron-down' : 'chevron-right';
    },
    ariaLabel() {
      return this.expanded ? __('Collapse') : __('Expand');
    },
  },
};
</script>

<template>
  <div>
    <div class="collapsible clickable d-flex align-items-center px-3 py-2" @click="toggle()">
      <gl-button
        :aria-label="ariaLabel"
        variant="blank"
        class="collapsible-toggle square s24 mr-2"
        @click.stop="toggle()"
      >
        <icon :name="collapseIcon" :size="16" />
      </gl-button>
      <span v-if="expanded">{{ __('Collapse') }}</span>
      <span v-else>
        <slot name="header"></slot>
      </span>
    </div>
    <div v-show="expanded">
      <slot name="content"></slot>
    </div>
  </div>
</template>
