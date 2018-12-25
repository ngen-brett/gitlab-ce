<script>
import { GlLink, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';
import popover from '~/vue_shared/directives/popover';

const popoverTitle = __(
  `This pipeline makes use of a predefined CI/CD configuration enabled by <b>Auto DevOps.</b>`,
);

export default {
  components: {
    UserAvatarLink,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    popover,
  },
  props: {
    pipeline: {
      type: Object,
      required: true,
    },
    autoDevopsHelpPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    user() {
      return this.pipeline.user;
    },
    popoverOptions() {
      return {
        html: true,
        trigger: 'focus',
        placement: 'top',
        title: `<div class="autodevops-title">
            ${popoverTitle}
          </div>`,
        content: `<a
            class="autodevops-link"
            href="${this.autoDevopsHelpPath}"
            target="_blank"
            rel="noopener noreferrer nofollow">
            ${__('Learn more about Auto DevOps')}
          </a>`,
      };
    },
  },
};
</script>
<template>
  <div class="table-section section-15 d-none d-sm-none d-md-block pipeline-tags">
    <gl-link :href="pipeline.path" class="js-pipeline-url-link">
      <span class="pipeline-id">#{{ pipeline.id }}</span>
    </gl-link>
    <span>by</span>
    <user-avatar-link
      v-if="user"
      :link-href="user.path"
      :img-src="user.avatar_url"
      :tooltip-text="user.name"
      class="js-pipeline-url-user"
    />
    <span v-if="!user" class="js-pipeline-url-api api"> API </span>
    <div class="label-container">
      <span
        v-if="pipeline.flags.latest"
        v-gl-tooltip
        :title="__('Latest pipeline for this branch')"
        class="js-pipeline-url-latest badge badge-success"
      >
        {{ s__('PipelineFlags|latest') }}
      </span>
      <span
        v-if="pipeline.flags.yaml_errors"
        v-gl-tooltip
        :title="pipeline.yaml_errors"
        class="js-pipeline-url-yaml badge badge-danger"
      >
        {{ s__('PipelineFlags|yaml invalid') }}
      </span>
      <span
        v-if="pipeline.flags.failure_reason"
        v-gl-tooltip
        :title="pipeline.failure_reason"
        class="js-pipeline-url-failure badge badge-danger"
      >
        {{ s__('PipelineFlags|error') }}
      </span>
      <gl-link
        v-if="pipeline.flags.auto_devops"
        v-popover="popoverOptions"
        tabindex="0"
        class="js-pipeline-url-autodevops badge badge-info autodevops-badge"
        role="button"
      >
        {{ s__('PipelineFlags|Auto DevOps') }}
      </gl-link>
      <span v-if="pipeline.flags.stuck" class="js-pipeline-url-stuck badge badge-warning">
        {{ s__('PipelineFlags|stuck') }}
      </span>
      <span
        v-if="pipeline.flags.merge_request"
        v-gl-tooltip
        :title="__('This pipeline is run in a merge request context')"
        class="js-pipeline-url-mergerequest badge badge-info"
      >
        {{ s__('PipelineFlags|merge request') }}
      </span>
    </div>
  </div>
</template>
