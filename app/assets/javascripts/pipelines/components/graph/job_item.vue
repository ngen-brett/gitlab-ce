<script>
import ActionComponent from './action_component.vue';
import JobNameComponent from './job_name_component.vue';
import { GlTooltipDirective, GlLink } from '@gitlab/ui';
import { sprintf } from '~/locale';
import delayedJobMixin from '~/jobs/mixins/delayed_job_mixin';
import TooltipOnTruncate from '~/vue_shared/components/tooltip_on_truncate.vue';



/**
 * Renders the badge for the pipeline graph and the job's dropdown.
 *
 * The following object should be provided as `job`:
 *
 * {
 *   "id": 4256,
 *   "name": "test",
 *   "status": {
 *     "icon": "status_success",
 *     "text": "passed",
 *     "label": "passed",
 *     "group": "success",
 *     "tooltip": "passed",
 *     "details_path": "/root/ci-mock/builds/4256",
 *     "action": {
 *       "icon": "retry",
 *       "title": "Retry",
 *       "path": "/root/ci-mock/builds/4256/retry",
 *       "method": "post"
 *     }
 *   }
 * }
 */

export default {
  components: {
    ActionComponent,
    JobNameComponent,
    GlLink,
    TooltipOnTruncate,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [delayedJobMixin],
  props: {
    job: {
      type: Object,
      required: true,
    },
    cssClassJobName: {
      type: String,
      required: false,
      default: '',
    },
    dropdownLength: {
      type: Number,
      required: false,
      default: Infinity,
    },
  },
  computed: {
    status() {
      return this.job && this.job.status ? this.job.status : {};
    },

    tooltipText() {
      const textBuilder = [];
      const { name: jobName } = this.job;

      if (jobName) {
        textBuilder.push(jobName);
      }

      const { tooltip: statusTooltip } = this.status;
      if (jobName && statusTooltip) {
        textBuilder.push('-');
      }

      if (statusTooltip) {
        if (this.isDelayedJob) {
          textBuilder.push(sprintf(statusTooltip, { remainingTime: this.remainingTime }));
        } else {
          textBuilder.push(statusTooltip);
        }
      }

      return textBuilder.join(' ');
    },
    /**
     * Verifies if the provided job has an action path
     *
     * @return {Boolean}
     */
    hasAction() {
      return this.job.status && this.job.status.action && this.job.status.action.path;
    },
  },
  methods: {
    pipelineActionRequestComplete() {
      this.$emit('pipelineActionRequestComplete');
    },
    getCiTextSpan(el) {
      return el.querySelector('.ci-status-text');
    }
  },
};
</script>
<template>
  <div class="ci-job-component">
    <gl-link
      v-if="status.has_details"
      :href="status.details_path"
      :title="tooltipText"
      :class="cssClassJobName"
      class="js-pipeline-graph-job-link qa-job-link"
    >
      <tooltip-on-truncate
       class="grab-me"
       title="dfjonajkdnljnvsnvljhsfbhvdfhjsbhjfbdhjvb"
       :truncate-target="getCiTextSpan"
       placement="bottom">
       <job-name-component :name="job.name" :status="job.status" />
     </tooltip-on-truncate>

    </gl-link>

    <div
      v-else
      :title="tooltipText"
      :class="cssClassJobName"
      class="js-job-component-tooltip non-details-job-component"
    >
      <tooltip-on-truncate
       class="grab-me"
       title="dfjonajkdnljnvsnvljhsfbhvdfhjsbhjfbdhjvb"
       :truncate-target="getCiTextSpan"
       placement="bottom">
       <job-name-component :name="job.name" :status="job.status" />
     </tooltip-on-truncate>
    </div>

    <action-component
      v-if="hasAction"
      :tooltip-text="status.action.title"
      :link="status.action.path"
      :action-icon="status.action.icon"
      @pipelineActionRequestComplete="pipelineActionRequestComplete"
    />
  </div>
</template>
