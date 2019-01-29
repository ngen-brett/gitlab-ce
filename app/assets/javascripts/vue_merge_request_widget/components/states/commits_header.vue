<script>
import { __, n__ } from '~/locale';
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
  },
  data() {
    return {
      expanded: false,
    };
  },
  computed: {
    collapseIcon() {
      return this.expanded ? 'chevron-down' : 'chevron-right';
    },
    commitsCountMessage() {
      return this.isSquashEnabled
        ? '1 commit'
        : `${this.commitsCount} ${n__('commit', 'commits', 3)}`;
    },
    modifyLinkMessage() {
      return this.isSquashEnabled ? __('Modify commit messages') : __('Modify merge commit');
    },
    ariaLabel() {
      return this.expanded ? __('Collapse') : __('Expand');
    },
  },
  methods: {
    toggle() {
      this.expanded = !this.expanded;
    },
  },
};
</script>

<template>
  <div>
    <div
      ref="header"
      class="js-mr-widget-commits-count mr-widget-extension d-flex align-items-center px-3 py-2"
      @click="toggle()"
    >
      <div
        class="w-3 h-3 d-flex-center append-right-default commit-edit-toggle"
        role="button"
        :aria-label="ariaLabel"
        @click.stop="toggle()"
      >
        <icon :name="collapseIcon" :size="16" />
      </div>
      <span v-if="expanded">Collapse</span>
      <span v-else>
        <strong class="commits-count-message">{{ commitsCountMessage }}</strong> and
        <strong>1 merge commit</strong> will be added to
        <span class="label-branch">{{ targetBranch }}.</span>
        <button type="button" class="btn-link btn-blank">{{ modifyLinkMessage }}</button>
      </span>
    </div>
    <div v-show="expanded"><slot></slot></div>
  </div>
</template>
