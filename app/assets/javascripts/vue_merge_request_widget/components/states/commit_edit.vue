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
  data() {
    return {
      includeAllCommitMessages: false,
      includeMergeCommitDescription: false,
    };
  },
  computed: {
    labelMessage() {
      return this.squash ? 'Squash commit message' : 'Merge commit message';
    },
  },
};
</script>

<template>
  <li>
    <div class="commit-message-editor">
      <div class="commit-message-label">
        <label class="col-form-label" for="commit-message">
          <strong>{{ labelMessage }}</strong>
        </label>
        <button v-if="squash" type="button" class="btn-link btn-blank">
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
      <textarea
        id="commit-message"
        :value="value"
        @input="$emit('input', $event.target.value)"
        class="form-control js-commit-message"
        required="required"
        rows="14"
        name="Commit message"
      ></textarea>
      <label v-if="squash">
        <input v-model="includeAllCommitMessages" id="include-all-commits" type="checkbox" />
        Include all commit messages
      </label>
      <label v-else>
        <input v-model="includeMergeCommitDescription" id="include-description" type="checkbox" />
        Include merge commit description
      </label>
    </div>
  </li>
</template>
