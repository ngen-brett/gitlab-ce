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
    },
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
        <template v-if="squash && commits.length">
          <button
            type="button"
            class="btn-link btn-blank"
            data-toggle="dropdown"
            aria-expanded="false"
          >
            Use an existing commit message
            <icon
              name="chevron-down"
              :size="16"
              aria-hidden="true"
              class="commits-header-icon"
              @click.stop="$emit('toggleCommitsList')"
            />
          </button>
          <div class="dropdown-menu dropdown-select dropdown-menu-selectable">
            <div class="dropdown-content">
              <ul>
                <li
                  v-for="commit in commits"
                  :key="commit.sha"
                  @click="$emit('updateCommitMessage', commit.title)"
                >
                  {{ commit.title }}
                </li>
              </ul>
            </div>
          </div>
        </template>
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
        <input
          id="include-all-commits"
          type="checkbox"
          @change="$emit('includeAllCommits', $event.target.checked)"
        />
        Include all commit messages
      </label>
      <label v-else>
        <input id="include-description" type="checkbox" @change="$emit('updateCommitMessage')" />
        Include merge commit description
      </label>
    </div>
  </li>
</template>
