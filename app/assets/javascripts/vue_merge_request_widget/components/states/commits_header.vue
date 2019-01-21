<script>
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
  },
  data() {
    return {
      isCommitExpanded: false,
    };
  },
  methods: {
    handleToggleCommits() {
      this.isCommitExpanded = !this.isCommitExpanded;
    },
  },
  computed: {
    collapseIcon() {
      return this.isCommitExpanded ? 'chevron-down' : 'chevron-right';
    },
  },
};
</script>

<template>
  <div
    ref="header"
    class="js-file-title file-title file-title-flex-parent mr-widget-commits-count"
    @click="handleToggleCommits()"
  >
    <icon
      :name="collapseIcon"
      :size="16"
      aria-hidden="true"
      class="diff-toggle-caret append-right-5"
      @click.stop="handleToggleCommits"
    />
    <span>Test</span>
  </div>
</template>
