<script>
export default {
  name: 'MergeCommitDetails',
  props: {
    isMergeButtonDisabled: { type: Boolean },
    commitMessage: { type: String },
    commitMessageLinkTitle: { type: String },
    ffOnlyEnabled: { type: Boolean },
    squash: { type: Boolean },
  },
  data() {
    return {
      showCommitMessageEditor: false,
    };
  },
  methods: {
    toggleCommitMessageEditor() {
      this.showCommitMessageEditor = !this.showCommitMessageEditor;
    },
  },
};
</script>

<template>
  <li>
    <div class="commit flex-row">
      <div class="avatar-cell d-none d-sm-block">
        <img
          alt="Ash McKenzie's avatar"
          src="https://www.gravatar.com/avatar/79e8be0c27f341afc67c0ab9f9030d17?s=72&amp;d=identicon"
          class="avatar s36 d-none d-sm-inline"
          title="Ash McKenzie"
        />
      </div>
      <div class="commit-detail flex-list">
        <div class="commit-content qa-commit-content">
          <div class="committer">
            <a class="commit-author-link" href="mailto:amckenzie@gitlab.com">Ash McKenzie</a>
            <template v-if="squash">
              authored
              <time
                class="js-timeago js-timeago-render"
                title=""
                datetime="2018-12-12T02:25:37Z"
                data-toggle="tooltip"
                data-placement="bottom"
                data-container="body"
                data-original-title="Dec 12, 2018 2:25am"
                data-tid="29"
                >3 weeks ago</time
              ></template
            >
          </div>
          <span class="commit-row-message item-title"> {{ commitMessage }} </span>
        </div>
        <div class="commit-actions flex-row d-none d-sm-flex">
          <span v-if="ffOnlyEnabled" class="js-fast-forward-message">
            Fast-forward merge without a merge commit
          </span>

          <button
            v-else
            :disabled="isMergeButtonDisabled"
            class="js-modify-commit-message-button btn btn-default btn-sm"
            type="button"
            @click="toggleCommitMessageEditor"
          >
            Edit message
          </button>
        </div>
      </div>
    </div>
    <div v-if="showCommitMessageEditor" class="prepend-top-default commit-message-editor">
      <div class="form-group clearfix">
        <label class="col-form-label" for="commit-message"> Commit message </label>
        <div class="col-sm-10">
          <div class="commit-message-container">
            <div class="max-width-marker"></div>
            <textarea
              id="commit-message"
              :value="commitMessage"
              @change="$emit('changeCommitMessage', $event.target.value);"
              class="form-control js-commit-message"
              required="required"
              rows="14"
              name="Commit message"
            ></textarea>
          </div>
          <p class="hint">Try to keep the first line under 52 characters and the others under 72</p>
          <div class="hint" v-if="!squash">
            <a href="#" @click.prevent="$emit('updateCommitMessage');">
              {{ commitMessageLinkTitle }}
            </a>
          </div>
        </div>
      </div>
    </div>
  </li>
</template>
