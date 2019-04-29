<script>
import { s__ } from '~/locale';
import Flash from '../../../flash';
import statusIcon from '../mr_widget_status_icon.vue';
import MrWidgetAuthor from '../../components/mr_widget_author.vue';
import eventHub from '../../event_hub';

export default {
  name: 'MRWidgetWhenPipelineSucceeds',
  components: {
    MrWidgetAuthor,
    statusIcon,
  },
  props: {
    mr: {
      type: Object,
      required: true,
      default: () => ({}),
    },
    service: {
      type: Object,
      required: true,
      default: () => ({}),
    },
  },
  data() {
    return {
      isCancellingAutoMerge: false,
      isRemovingSourceBranch: false,
    };
  },
  computed: {
    canRemoveSourceBranch() {
      const {
        shouldRemoveSourceBranch,
        canRemoveSourceBranch,
        mergeUserId,
        currentUserId,
      } = this.mr;

      return !shouldRemoveSourceBranch && canRemoveSourceBranch && mergeUserId === currentUserId;
    },
    statusText() {
      if (this.mr.mergeTrainsEnabled) {
        if (this.mr.mergeTrainsCount === 0) {
          return s__('mrWidget|to start a merge train when the pipeline succeeds');
        }

        return s__('mrWidget|to be added to the merge train when the pipeline succeeds');
      }

      return s__('mrWidget|to be merged automatically when the pipeline succeeds');
    },
    cancelButtonText() {
      if (this.mr.mergeTrainsEnabled) {
        if (this.mr.mergeTrainsCount === 0) {
          return s__('mrWidget|Cancel start merge train');
        }

        return s__('mrWidget|Cancel add to merge train');
      }

      return s__('mrWidget|Cancel automatic merge');
    },
  },
  methods: {
    cancelAutomaticMerge() {
      this.isCancellingAutoMerge = true;
      this.service
        .cancelAutomaticMerge()
        .then(res => res.data)
        .then(data => {
          eventHub.$emit('UpdateWidgetData', data);
        })
        .catch(() => {
          this.isCancellingAutoMerge = false;
          Flash('Something went wrong. Please try again.');
        });
    },
    removeSourceBranch() {
      const options = {
        sha: this.mr.sha,
        merge_when_pipeline_succeeds: true,
        should_remove_source_branch: true,
      };

      this.isRemovingSourceBranch = true;
      this.service
        .merge(options)
        .then(res => res.data)
        .then(data => {
          if (data.status === 'merge_when_pipeline_succeeds') {
            eventHub.$emit('MRWidgetUpdateRequested');
          }
        })
        .catch(() => {
          this.isRemovingSourceBranch = false;
          Flash('Something went wrong. Please try again.');
        });
    },
  },
};
</script>
<template>
  <div class="mr-widget-body media">
    <status-icon status="success" />
    <div class="media-body">
      <h4 class="d-flex align-items-start">
        <span class="append-right-10">
          {{ s__('mrWidget|Set by') }}
          <mr-widget-author :author="mr.setToMWPSBy" />
          {{ statusText }}
        </span>
        <a
          v-if="mr.canCancelAutomaticMerge"
          :disabled="isCancellingAutoMerge"
          role="button"
          href="#"
          class="btn btn-sm btn-default js-cancel-auto-merge"
          @click.prevent="cancelAutomaticMerge"
        >
          <i v-if="isCancellingAutoMerge" class="fa fa-spinner fa-spin" aria-hidden="true"> </i>
          {{ cancelButtonText }}
        </a>
      </h4>
      <section class="mr-info-list">
        <p>
          {{ s__('mrWidget|The changes will be merged into') }}
          <a :href="mr.targetBranchPath" class="label-branch"> {{ mr.targetBranch }} </a>
        </p>
        <p v-if="mr.shouldRemoveSourceBranch">
          {{ s__('mrWidget|The source branch will be deleted') }}
        </p>
        <p v-else class="d-flex align-items-start">
          <span class="append-right-10">
            {{ s__('mrWidget|The source branch will not be deleted') }}
          </span>
          <a
            v-if="canRemoveSourceBranch"
            :disabled="isRemovingSourceBranch"
            role="button"
            class="btn btn-sm btn-default js-remove-source-branch"
            href="#"
            @click.prevent="removeSourceBranch"
          >
            <i v-if="isRemovingSourceBranch" class="fa fa-spinner fa-spin" aria-hidden="true"> </i>
            {{ s__('mrWidget|Delete source branch') }}
          </a>
        </p>
      </section>
    </div>
  </div>
</template>
