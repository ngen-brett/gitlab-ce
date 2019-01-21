<script>
import Icon from '~/vue_shared/components/icon.vue';
export default {
  components: {
    Icon,
  },
  props: {
    value: {
      type: String,
      required: true,
      default: '',
    },
    squash: {
      type: Boolean,
      required: false,
    },
  },
};
</script>

<template>
  <li>
    <div v-if="squash"><strong>Commit author placeholder</strong></div>
    <div class="prepend-top-default commit-message-editor">
      <div class="commit-message-label">
        <label class="col-form-label" for="commit-message">
          <strong>Squash commit message</strong>
        </label>
        <button type="button" class="btn-link btn-blank">
          Use an existing commit message
          <icon
            name="chevron-down"
            :size="16"
            aria-hidden="true"
            class="commits-header-icon"
            @click.stop="$emit('toggleCommitsList')"
          />
        </button>
      </div>
      <div class="commit-message-container">
        <textarea
          id="commit-message"
          :value="value"
          @input="$emit('input', $event.target.value)"
          class="form-control js-commit-message"
          required="required"
          rows="14"
          name="Commit message"
        ></textarea>
      </div>
    </div>
  </li>
</template>
