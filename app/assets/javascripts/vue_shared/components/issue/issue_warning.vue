<script>
import _ from 'underscore';
import { mapGetters } from 'vuex';
import { __, sprintf } from '~/locale';
import icon from '../../../vue_shared/components/icon.vue';

export default {
  components: {
    icon,
  },
  props: {
    isLocked: {
      type: Boolean,
      default: false,
      required: false,
    },
    isConfidential: {
      type: Boolean,
      default: false,
      required: false,
    },
  },
  computed: {
    ...mapGetters(['getNoteableDataByProp']),
    warningIcon() {
      if (this.isConfidential) return 'eye-slash';
      if (this.isLocked) return 'lock';

      return '';
    },
    isLockedAndConfidential() {
      return this.isConfidential && this.isLocked;
    },
    confidentialAndLockedDiscussionText() {
      return __(`
        This issue is
        ${this.buildConfidentialIssueDocsLink('confidential')}
        and
        ${this.buildLockedDiscussionDocsLink('locked')}.
      `);
    },
  },
  methods: {
    buildLockedDiscussionDocsLink(text) {
      return sprintf(
        '%{linkStart}%{text}%{linkEnd}',
        {
          linkStart: `<a href="${_.escape(
            this.getNoteableDataByProp('locked_discussion_docs_path'),
          )}" target="_blank" rel="noopener noreferrer">`,
          linkEnd: '</a>',
          text,
        },
        false,
      );
    },
    buildConfidentialIssueDocsLink(text) {
      return sprintf(
        '%{linkStart}%{text}%{linkEnd}',
        {
          linkStart: `<a href="${_.escape(
            this.getNoteableDataByProp('confidential_issues_docs_path'),
          )}" target="_blank" rel="noopener noreferrer">`,
          linkEnd: '</a>',
          text,
        },
        false,
      );
    },
  },
};
</script>
<template>
  <div class="issuable-note-warning">
    <icon v-if="!isLockedAndConfidential" :name="warningIcon" :size="16" class="icon inline" />

    <span v-if="isLockedAndConfidential">
      <span v-html="confidentialAndLockedDiscussionText"></span>
      {{
        __(`People without permission will never get a notification and won't be able to comment.`)
      }}
    </span>

    <span v-else-if="isConfidential">
      {{ __('This is a confidential issue.') }}
      {{ __('People without permission will never get a notification.') }}
      <span v-html="buildConfidentialIssueDocsLink(__('Learn more'))"></span>
    </span>

    <span v-else-if="isLocked">
      {{ __('This issue is locked.') }}
      {{ __('Only project members can comment.') }}
      <span v-html="buildLockedDiscussionDocsLink(__('Learn more'))"></span>
    </span>
  </div>
</template>
