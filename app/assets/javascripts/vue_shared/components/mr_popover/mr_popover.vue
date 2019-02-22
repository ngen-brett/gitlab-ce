<script>
import { mapActions, mapGetters } from 'vuex';
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
    projectID: {
      type: String,
      required: true,
    },
    mergeRequestIID: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['getMergeRequest']),
    formattedTime() {
      if (Object.keys(this.mergeRequest).length === 0) {
        return null;
      }

      return this.timeFormated(this.mergeRequest.created_at);
    },
    mergeRequest() {
      return this.getMergeRequest(this.projectID, this.mergeRequestIID);
    },
    loading() {
      return this.mergeRequest.loading;
    },
    mrData() {
      return this.mergeRequest.data || {};
    },
    error() {
      return this.mergeRequest.error;
    },
    pipelineStatus() {
      return this.mrData.pipeline && this.mrData.pipeline.status;
    },
    stateHumanName() {
      return this.mrData.state_human_name;
    },
    stateIconName() {
      return this.mrData.state_icon_name;
    },
  },
  created() {
    const { projectID, mergeRequestIID } = this;
    this.fetchMergeRequestData({ projectID, mergeRequestIID });
  },
  methods: mapActions(['fetchMergeRequestData']),
};
</script>

<template>
  <gl-popover :target="target" boundary="viewport" width="300" placement="top" show>
    <div v-if="loading">
      Loading...
    </div>
    <div v-else>
      <div class="d-flex-center justify-content-between">
        <div>
          <!-- TODO: make dynamic statux-box class -->
          <div :class="`issuable-status-box status-box status-box-${stateHumanName.toLowerCase()}`">
            {{ stateHumanName }}
          </div>
          <span class="text-secondary">Opened <time v-text="formattedTime"></time></span>
        </div>
        <ci-icon
          v-if="pipelineStatus"
          :status="{
            group: pipelineStatus,
            icon: `status_${pipelineStatus}`,
          }"
        />
      </div>
      <h5>{{ mrData && mrData.description }}</h5>
      <div class="text-secondary">{{ mrData && mrData.project_path }}</div>
    </div>
  </gl-popover>
</template>
