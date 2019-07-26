<script>
import uncollapsedAssigneeMixins from '../../mixins/uncollapsed_assignee_mixins';
import assigneeAvatar from '../assignees/assignee_avatar.vue';
import { __, sprintf } from '~/locale';

export default {
  components: {
    assigneeAvatar,
  },
  mixins: [uncollapsedAssigneeMixins],
  computed: {
    assigneeUsername() {
      return `@${this.user.username}`;
    },
    tooltipTitle() {
      const mergeStatus = this.user.can_merge ? __('Can merge') : __('Cannot merge');
      return sprintf(__('%{mergeStatus}'), { mergeStatus });
    },
  },
};
</script>
<template>
  <a
    :href="assigneeUrl(user)"
    :data-title="tooltipTitle"
    class="author-link bold has-tooltip"
    data-container="body"
    data-placement="left"
  >
    <div
      :data-title="tooltipTitle"
      class="avatar-wrap has-tooltip"
      data-container="body"
      data-placement="left"
    >
      <assignee-avatar :user="user" :img-size="32" />
    </div>
    <span class="author"> {{ user.name }} </span>
    <span class="username"> {{ assigneeUsername }} </span>
  </a>
</template>
