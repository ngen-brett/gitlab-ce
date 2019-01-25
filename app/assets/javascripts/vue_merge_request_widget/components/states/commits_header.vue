<script>
import { pluralize } from '~/lib/utils/text_utility';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
  },
  props: {
    isSquashEnabled: {
      type: Boolean,
      required: true,
      default: false,
    },
    commitsCount: {
      type: Number,
      required: false,
      default: 0,
    },
    targetBranch: {
      type: String,
      required: true,
      default: '',
    },
    expanded: {
      type: Boolean,
      required: true,
      default: false,
    },
  },
  computed: {
    collapseIcon() {
      return this.expanded ? 'chevron-down' : 'chevron-right';
    },
    commitsCountMessage() {
      return this.isSquashEnabled
        ? '1 commit'
        : `${this.commitsCount} ${pluralize('commit', this.commitsCount)}`;
    },
    modifyLinkMessage() {
      return this.isSquashEnabled ? 'Modify commit messages' : 'Modify merge commit';
    },
  },
};
</script>

<template>
  <div
    ref="header"
    class="file-title mr-widget-commits-count"
    :class="{ collapsed: !expanded }"
    @click="$emit('toggleCommitsList')"
  >
    <icon
      :name="collapseIcon"
      :size="16"
      aria-hidden="true"
      class="commits-header-icon"
      @click.stop="$emit('toggleCommitsList')"
    />
    <span v-if="expanded">Collapse</span>
    <span v-else>
      <strong class="commits-count-message">{{ commitsCountMessage }}</strong> and
      <strong>1 merge commit</strong> will be added to
      <span class="label-branch">{{ targetBranch }}.</span>
      <button type="button" class="btn-link btn-blank">{{ modifyLinkMessage }}</button>
    </span>
  </div>
</template>
