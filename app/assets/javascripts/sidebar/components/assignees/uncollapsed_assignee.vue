<script>
import uncollapsedAssigneeMixins from '../../mixins/uncollapsed_assignee_mixins';
import assigneeAvatar from '../assignees/assignee_avatar.vue';
import { __, sprintf } from '~/locale';

export default {
  components: {
    assigneeAvatar,
  },
  mixins: [uncollapsedAssigneeMixins],
  props: {
    index: {
      type: Number,
      required: true,
    },
    defaultRenderCount: {
      type: Number,
      required: true,
    },
    showLess: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    renderAssignee() {
      return !this.showLess || (this.index < this.defaultRenderCount && this.showLess);
    },
    tooltipTitle() {
      const mergeStatus = this.user.can_merge ? __('can merge') : __('cannot merge');
      return sprintf(__('%{userName} (%{mergeStatus})'), { userName: this.user.name, mergeStatus });
    },
  },
};
</script>
<template>
  <div v-if="renderAssignee" class="user-item">
    <a
      :href="assigneeUrl(user)"
      :data-title="tooltipTitle"
      class="user-link has-tooltip"
      data-container="body"
      data-placement="bottom"
    >
      <assignee-avatar :user="user" :img-size="32" />
    </a>
  </div>
</template>
