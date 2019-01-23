<script>
export default {
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
    commits: {
      type: Array,
      required: false,
      default: () => [],
    },
    label: {
      type: String,
      required: true,
      default: '',
    },
    inputId: {
      type: String,
      required: true,
      default: 'commit-message-edit',
    },
  },
  data() {
    return {
      allCommitsIncluded: false,
      tempSquashCommitMessage: '',
    };
  },
  methods: {
    handleAllCommitMessages(showAllCommitMessages) {
      if (showAllCommitMessages) {
        this.tempSquashCommitMessage = this.value;
        this.$emit('input', this.allCommitMessages);
      } else {
        this.$emit('input', this.tempSquashCommitMessage);
        this.tempSquashCommitMessage = '';
      }
    },
  },
};
</script>

<template>
  <li>
    <div class="commit-message-editor">
      <div class="commit-message-label">
        <label class="col-form-label" for="commit-message">
          <strong>{{ label }}</strong>
        </label>
        <slot name="header"></slot>
      </div>
      <textarea
        :id="inputId"
        :value="value"
        @input="$emit('input', $event.target.value)"
        class="form-control js-commit-message js-gfm-input"
        required="required"
        rows="14"
        name="Commit message"
      ></textarea>
      <slot name="checkbox"></slot>
    </div>
  </li>
</template>
