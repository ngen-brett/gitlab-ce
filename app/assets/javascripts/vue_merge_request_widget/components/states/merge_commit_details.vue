<script>
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  name: 'MergeCommitDetails',
  components: {
    UserAvatarLink,
    TimeAgoTooltip,
    Icon,
  },
  props: {
    isMergeButtonDisabled: { type: Boolean },
    commitMessage: { type: String },
    commitMessageLinkTitle: { type: String },
    ffOnlyEnabled: { type: Boolean },
    squash: { type: Boolean },
  },
  computed: {
    author() {
      return this.commit.author || {};
    },
    authorName() {
      return this.author.name || this.commit.author_name;
    },
    authorClass() {
      return this.author.name ? 'js-user-link' : '';
    },
    authorId() {
      return this.author.id ? this.author.id : '';
    },
    authorUrl() {
      return this.author.web_url || `mailto:${this.commit.author_email}`;
    },
    authorAvatar() {
      return this.author.avatar_url || this.commit.author_gravatar_url;
    },
  },
  data() {
    return {
      showCommitMessageEditor: false,
      showCommitDescription: false,
      // TODO: move this to props when get an actual commit data from API
      commit: {
        author: {
          avatar_url:
            'https://www.gravatar.com/avatar/79e8be0c27f341afc67c0ab9f9030d17?s=72&amp;d=identicon',
          id: '12345',
          name: 'Ash Mackenzie',
        },
        author_email: 'amckenzie@gitlab.com',
        authored_date: '2018-12-05',
        description_html: 'Test description!',
      },
    };
  },
  methods: {
    toggleCommitMessageEditor() {
      this.showCommitMessageEditor = !this.showCommitMessageEditor;
    },
    toggleCommitDescription() {
      this.showCommitDescription = !this.showCommitDescription;
    },
  },
};
</script>

<template>
  <li>
    <div class="commit flex-row">
      <user-avatar-link
        :link-href="authorUrl"
        :img-src="authorAvatar"
        :img-alt="authorName"
        :img-size="36"
        class="avatar-cell d-none d-sm-block"
      />
      <div class="commit-detail flex-list">
        <div class="commit-content qa-commit-content">
          <div class="committer">
            <a
              :href="authorUrl"
              :class="authorClass"
              :data-user-id="authorId"
              v-text="authorName"
            ></a>
            <template v-if="squash">
              {{ s__('CommitWidget|authored') }}
              <time-ago-tooltip :time="commit.authored_date" />
            </template>
          </div>
          <span class="commit-row-message item-title"> {{ commitMessage }} </span>

          <button
            v-if="commit.description_html"
            class="text-expander js-toggle-button"
            type="button"
            :aria-label="__('Toggle commit description')"
            @click="toggleCommitDescription"
          >
            <icon :size="12" name="ellipsis_h" />
          </button>
          <pre
            v-if="commit.description_html"
            :style="[showCommitDescription ? { display: 'block' } : {}]"
            class="commit-row-description js-toggle-content append-bottom-8"
            v-html="commit.description_html"
          ></pre>
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
