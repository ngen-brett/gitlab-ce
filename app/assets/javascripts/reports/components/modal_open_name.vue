<script>
import { mapActions } from 'vuex';

export default {
  inject: {
    handleIssueClick: {
      from: 'handleIssueClick',
      default: () => () => {},
    },
  },
  props: {
    issue: {
      type: Object,
      required: true,
    },
    // failed || success
    status: {
      type: String,
      required: true,
    },
  },
  methods: {
    ...mapActions(['openModal']),
  },
};
</script>
<template>
  <button
    type="button"
    class="btn-link btn-blank text-left break-link vulnerability-name-button"
    @click="() => handleIssueClick({ issue, status })"
  >
    {{ issue.title }}
  </button>
</template>
