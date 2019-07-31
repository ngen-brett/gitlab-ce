<script>
import { mapGetters, createNamespacedHelpers } from 'vuex';

const { mapState: mapCommitState, mapActions: mapCommitActions } = createNamespacedHelpers(
  'commit',
);

export default {
  computed: {
    ...mapCommitState(['shouldCreateMR']),
    ...mapGetters([
      'hasMergeRequest',
      'isOnDefaultBranch',
      'isOnProtectedBranch',
      'canPushToBranch',
    ]),
    hideNewMrOption() {
      return !this.isOnDefaultBranch && this.hasMergeRequest && this.canPushToBranch;
    },
  },
  methods: {
    ...mapCommitActions(['toggleShouldCreateMR']),
  },
};
</script>

<template>
  <div v-if="!hideNewMrOption">
    <hr class="my-2" />
    <label class="mb-0">
      <input :checked="shouldCreateMR" type="checkbox" @change="toggleShouldCreateMR" />
      <span class="prepend-left-10">
        {{ __('Start a new merge request') }}
      </span>
    </label>
  </div>
</template>
