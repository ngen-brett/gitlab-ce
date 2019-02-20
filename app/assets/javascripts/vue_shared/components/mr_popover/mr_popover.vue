<script>
import { GlPopover, GlSkeletonLoading } from '@gitlab/ui';
import timeagoMixin from '../../mixins/timeago';

export default {
  name: 'MRPopover',
  components: {
    GlPopover,
    GlSkeletonLoading
  },
  mixins: [timeagoMixin],
  props: {
    target: {
      type: HTMLAnchorElement,
      required: true,
    },
    mergeRequest: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    formattedTime() {
      if (Object.keys(this.mergeRequest).length === 0) {
        return null;
      }
      return this.timeFormated(this.mergeRequest);
    }
  }
};
</script>

<template>
  <gl-popover  :target="target" boundary="viewport" placement="top" show>
    <p>{{ mergeRequest.state_icon_name }}</p>
    <p>{{ mergeRequest.state_human_name }}</p>
    <time v-text="formattedTime"></time>
    <h4>{{ mergeRequest.description }}</h4>
    <p>{{ mergeRequest.project_path }}</p>
  </gl-popover>
</template>
