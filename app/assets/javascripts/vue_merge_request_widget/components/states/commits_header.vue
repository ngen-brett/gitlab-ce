<script>
import { GlButton } from '@gitlab/ui';
import { __, n__, sprintf, s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
    GlButton,
  },
  props: {
    isSquashEnabled: {
      type: Boolean,
      required: true,
    },
    commitsCount: {
      type: Number,
      required: false,
      default: 0,
    },
    targetBranch: {
      type: String,
      required: true,
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
        ? __('1 commit')
        : `${this.commitsCount} ${n__('commit', 'commits', 3)}`;
    },
    modifyLinkMessage() {
      return this.isSquashEnabled ? __('Modify commit messages') : __('Modify merge commit');
    },
    ariaLabel() {
      return this.expanded ? __('Collapse') : __('Expand');
    },
    message() {
      const commitsCount = `<strong class="commits-count-message">${
        this.commitsCountMessage
      }</strong>`;
      const addingBlock = sprintf(
        s__('and %{commitMessage} will be added to'),
        {
          commitMessage: `<strong>${__('1 merge commit')}</strong>`,
        },
        false,
      );
      const targetBranch = `<span class="label-branch">${this.targetBranch}</span>`;

      return `${commitsCount} ${addingBlock} ${targetBranch}.`;
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
        class="w-3 h-3 d-flex-center append-right-10 commit-edit-toggle"
        role="button"
        :aria-label="ariaLabel"
        @click.stop="toggle()"
      >
        <icon :name="collapseIcon" :size="16" />
      </div>
      <span v-if="expanded">{{ __('Collapse') }}</span>
      <span v-else>
        <span v-html="message"></span>
        <gl-button variant="link">{{ modifyLinkMessage }}</gl-button>
      </span>
    </div>
    <div v-show="expanded"><slot></slot></div>
  </div>
</template>
