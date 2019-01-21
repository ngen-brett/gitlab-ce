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
  methods: {
    handleToggleCommits() {
      this.isCommitExpanded = !this.isCommitExpanded;
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
  },
};
</script>

<template>
  <div
    ref="header"
    class="js-file-title file-title mr-widget-commits-count"
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
      <strong>{{ commitsCountMessage }}</strong> and <strong>1 merge commit</strong> will be added
      to <span class="label-branch">{{ targetBranch }}.</span>
      <button type="button" class="btn-link btn-blank">Modify commit message</button>
    </span>
  </div>
</template>
