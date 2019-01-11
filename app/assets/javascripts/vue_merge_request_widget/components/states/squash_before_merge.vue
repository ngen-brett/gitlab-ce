<script>
import Icon from '~/vue_shared/components/icon.vue';
import eventHub from '~/vue_merge_request_widget/event_hub';
import tooltip from '~/vue_shared/directives/tooltip';

export default {
  components: {
    Icon,
  },
  directives: {
    tooltip,
  },
  props: {
    value: {
      type: Boolean,
      required: true,
    },
    helpPath: {
      type: String,
      required: false,
      default: '',
    },
    isDisabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>

<template>
  <div class="accept-control inline">
    <label class="merge-param-checkbox">
      <input
        :value="value"
        :disabled="isDisabled"
        @change="$emit('input', $event.target.checked);"
        type="checkbox"
        name="squash"
        class="qa-squash-checkbox"
      />
      {{ __('Squash commits') }}
    </label>
    <a
      v-tooltip
      v-if="helpPath"
      :href="helpPath"
      data-title="About this feature"
      data-placement="bottom"
      target="_blank"
      rel="noopener noreferrer nofollow"
      data-container="body"
    >
      <icon name="question-o" />
    </a>
  </div>
</template>
