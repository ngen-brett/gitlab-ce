import { s__, sprintf } from '~/locale';

export default {
  computed: {
    text() {
      return sprintf(
        s__(`Milestones|Promoting %{milestoneTitle} will make it available for all projects inside %{groupName}.
        Existing project milestones with the same title will be merged.
        This action cannot be reversed.`),
        { milestoneTitle: this.milestoneTitle, groupName: this.groupName },
      );
    },
  },
};
