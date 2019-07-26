<script>
import assigneeAvatar from '../assignees/assignee_avatar.vue';

export default {
  components: {
    assigneeAvatar,
  },
  props: {
    user: {
      type: Object,
      required: true,
    },
    index: {
      type: Number,
      required: true,
    },
    length: {
      type: Number,
      required: true,
    },
  },
  computed: {
    shouldRenderCollapsedAssignee() {
      const firstTwo = this.length <= 2 && this.index <= 2;
      return this.index === 0 || firstTwo;
    },
  },
};
</script>

<template>
  <button v-if="shouldRenderCollapsedAssignee" type="button" class="btn-link">
    <assignee-avatar :user="user" :img-size="24" />
    <span class="author"> {{ user.name }} </span>
  </button>
</template>
