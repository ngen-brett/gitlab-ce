<script>
import { GlPopover, GlSkeletonLoading } from '@gitlab/ui';
import Icon from '../icon.vue';
import CiIcon from '../ci_icon.vue';
import timeagoMixin from '../../mixins/timeago';

export default {
  name: 'MRPopover',
  components: {
    GlPopover,
    GlSkeletonLoading,
    Icon,
    CiIcon,
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

      return this.timeFormated(this.mergeRequest.created_at);
    },
  },
};
</script>

<template>
  <gl-popover :target="target" boundary="viewport" width="300" placement="top" show>
    <div class="d-flex-center justify-content-between">
      <div>
        <div class="issuable-status-box status-box status-box-open">
          {{ mergeRequest.state_human_name }}
        </div>
        <span class="text-secondary">Opened <time v-text="formattedTime"></time></span>
      </div>
      <ci-icon v-if="mergeRequest.pipeline" :status="{ group: mergeRequest.pipeline.status, icon: `status_${mergeRequest.pipeline.status}` }" />
    </div>
    <h5>{{ mergeRequest.description }}</h5>
    <div class="text-secondary">{{ mergeRequest.project_path }}</div>
  </gl-popover>
</template>
