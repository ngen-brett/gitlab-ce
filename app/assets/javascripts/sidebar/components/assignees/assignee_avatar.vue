<script>
import { __, sprintf } from '~/locale';

export default {
  props: {
    user: {
      type: Object,
      required: true,
    },
    imgSize: {
      type: Number,
      required: true,
    },
  },
  methods: {
    assigneeAlt(user) {
      return sprintf(__("%{userName}'s avatar"), { userName: user.name });
    },
    avatarUrl(user) {
      return user.avatar || user.avatar_url || gon.default_avatar_url;
    },
  },
};
</script>

<template>
  <div>
    <img
      :alt="assigneeAlt(user)"
      :src="avatarUrl(user)"
      :width="imgSize"
      :class="`s${imgSize}`"
      class="avatar avatar-inline"
    />
    <i
      v-if="!user.can_merge"
      aria-hidden="true"
      data-hidden="true"
      class="fa fa-exclamation-triangle merge-icon"
    ></i>
  </div>
</template>
