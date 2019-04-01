<script>
import _ from 'underscore';
import { mapActions, mapState, mapGetters } from 'vuex';
import { sprintf, __ } from '~/locale';
import * as consts from '../../stores/modules/commit/constants';
import RadioGroup from './radio_group.vue';

export default {
  components: {
    RadioGroup,
  },
  computed: {
    ...mapState(['currentBranchId', 'changedFiles', 'stagedFiles']),
    ...mapGetters(['currentProject', 'currentBranch']),
    commitToCurrentBranchText() {
      return sprintf(
        __('Commit to %{branchName} branch'),
        { branchName: `<strong class="monospace">${_.escape(this.currentBranchId)}</strong>` },
        false,
      );
    },
    disableMergeRequestRadio() {
      return this.changedFiles.length > 0 && this.stagedFiles.length > 0;
    },
    shouldCreateMR: {
      get() {
        return this.$store.commit.shouldCreateMR;
      },
      set() {
        this.toggleShouldCreateMR();
      },
    },
  },
  watch: {
    disableMergeRequestRadio() {
      this.updateSelectedCommitAction();
    },
  },
  mounted() {
    this.updateSelectedCommitAction();
  },
  methods: {
    ...mapActions('commit', ['updateCommitAction', 'toggleShouldCreateMR']),
    updateSelectedCommitAction() {
      if (this.currentBranch && !this.currentBranch.can_push) {
        this.updateCommitAction(consts.COMMIT_TO_NEW_BRANCH);
      } else if (this.disableMergeRequestRadio) {
        this.updateCommitAction(consts.COMMIT_TO_CURRENT_BRANCH);
      }
    },
  },
  commitToCurrentBranch: consts.COMMIT_TO_CURRENT_BRANCH,
  commitToNewBranch: consts.COMMIT_TO_NEW_BRANCH,
  commitWithNewMR: consts.COMMIT_WITH_NEW_MR,
  currentBranchPermissionsTooltip: __(
    "This option is disabled as you don't have write permissions for the current branch",
  ),
};
</script>

<template>
  <div class="append-bottom-15 ide-commit-radios">
    <radio-group
      :value="$options.commitToCurrentBranch"
      :disabled="currentBranch && !currentBranch.can_push"
      :title="$options.currentBranchPermissionsTooltip"
    >
      <span class="ide-radio-label" v-html="commitToCurrentBranchText"> </span>
    </radio-group>
    <radio-group
      :value="$options.commitToNewBranch"
      :label="__('Create a new branch')"
      :show-input="true"
    />
    <hr class="my-2" />
    <label class="mb0">
      <input v-model="shouldCreateMR" type="checkbox" :value="$options.commitWithNewMR" />
      <span class="prepend-left-10">{{ __('Create a merge request for this branch') }}</span>
    </label>
  </div>
</template>
