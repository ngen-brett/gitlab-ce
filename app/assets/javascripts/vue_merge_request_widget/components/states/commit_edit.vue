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
  },
  data() {
    return {
      allCommitsIncluded: false,
      tempSquashCommitMessage: '',
    };
  },
  computed: {
    allCommitMessages() {
      return this.commits.reduce(
        (acc, current) => (acc ? acc + '\n\r' + current.title : current.title),
        '',
      );
    },
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
        id="commit-message"
        :value="value"
        @input="$emit('input', $event.target.value)"
        class="form-control js-commit-message js-gfm-input"
        required="required"
        rows="14"
        name="Commit message"
      ></textarea>
      <label v-if="squash">
        <input
          v-model="allCommitsIncluded"
          id="include-all-commits"
          type="checkbox"
          @change="handleAllCommitMessages($event.target.checked)"
        />
        Include all commit messages
      </label>
      <label v-else>
        <input
          id="include-description"
          type="checkbox"
          @change="$emit('updateCommitMessage', $event.target.checked)"
        />
        Include merge commit description
      </label>
    </div>
  </li>
</template>
