<script>
import ciIcon from '../../../vue_shared/components/ci_icon.vue';
import TooltipOnTruncate from '~/vue_shared/components/tooltip_on_truncate.vue';

/**
 * Component that renders both the CI icon status and the job name.
 * Used in
 *  - Badge component
 *  - Dropdown badge components
 */
export default {
  components: {
    ciIcon,
    TooltipOnTruncate
  },
  props: {
    name: {
      type: String,
      required: true,
    },

    status: {
      type: Object,
      required: true,
    },
  },
};
</script>
<template>
  <span class="ci-job-name-component">
    <ci-icon :status="status" />

    <!-- <span class="ci-status-text"> {{ name }} </span> -->
    <span class="ci-status-text">
      <tooltip-on-truncate
        title="dfjonajkdnljnvsnvljhsfbhvdfhjsbhjfbdhjvb"
        placement="top">
        dfjonajkdnljnvsnvljhsfbhvdfhjsbhjfbdhjvb
      </tooltip-on-truncate>
    </span>
  </span>
</template>
