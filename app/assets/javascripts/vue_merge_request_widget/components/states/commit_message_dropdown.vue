<script>
import Icon from '~/vue_shared/components/icon.vue';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';

export default {
  components: {
    Icon,
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    commits: {
      type: Array,
      required: true,
      default: () => [],
    },
  },
};
</script>

<template>
  <div>
    <gl-dropdown
      right
      no-caret
      text="Use an existing commit message"
      variant="link"
      class="mr-commit-dropdown"
    >
      <gl-dropdown-item
        v-for="commit in commits"
        :key="commit.sha"
        @click="$emit('input', commit.title)"
      >
        <span class="monospace append-right-10">{{ commit.sha }}</span> {{ commit.title }}
      </gl-dropdown-item>
    </gl-dropdown>
  </div>
</template>
