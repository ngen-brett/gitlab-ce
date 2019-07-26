<script>
import { __, sprintf } from '~/locale';
import tooltip from '~/vue_shared/directives/tooltip';
import uncollapsedAssignee from '../assignees/uncollapsed_assignee.vue';
import collapsedAssignee from '../assignees/collapsed_assignee.vue';
import assigneeAvatar from '../assignees/assignee_avatar.vue';
import uncollapsedSingleAssignee from '../assignees/uncollapsed_single_assignee.vue';

export default {
  name: 'Assignees',
  directives: {
    tooltip,
  },
  components: {
    uncollapsedAssignee,
    collapsedAssignee,
    assigneeAvatar,
    uncollapsedSingleAssignee,
  },
  props: {
    rootPath: {
      type: String,
      required: true,
    },
    users: {
      type: Array,
      required: true,
    },
    editable: {
      type: Boolean,
      required: true,
    },
    issuableType: {
      type: String,
      require: true,
      default: 'issue',
    },
  },
  data() {
    return {
      defaultRenderCount: 5,
      defaultMaxCounter: 99,
      showLess: true,
    };
  },
  computed: {
    firstUser() {
      return this.users[0];
    },
    hasMoreThanTwoAssignees() {
      return this.users.length > 2;
    },
    hasMoreThanOneAssignee() {
      return this.users.length > 1;
    },
    hasAssignees() {
      return this.users.length > 0;
    },
    hasNoUsers() {
      return !this.users.length;
    },
    hasOneUser() {
      return this.users.length === 1;
    },
    renderShowMoreSection() {
      return this.users.length > this.defaultRenderCount;
    },
    numberOfHiddenAssignees() {
      return this.users.length - this.defaultRenderCount;
    },
    isHiddenAssignees() {
      return this.numberOfHiddenAssignees > 0;
    },
    hiddenAssigneesLabel() {
      const { numberOfHiddenAssignees } = this;
      return sprintf(__('+ %{numberOfHiddenAssignees} more'), { numberOfHiddenAssignees });
    },
    collapsedTooltipTitle() {
      const maxRender = Math.min(this.defaultRenderCount, this.sortedAssigness.length);
      const renderUsers = this.sortedAssigness.slice(0, maxRender);

      if (!renderUsers.length) {
        return __('Assignee(s)');
      }

      if (renderUsers.length === 1) {
        const [user] = renderUsers;
        const mergeStatus = user.can_merge ? __('can merge') : __('cannot merge');
        return sprintf(__('%{userName} (%{mergeStatus})'), { userName: user.name, mergeStatus });
      }

      const names = renderUsers.map(u => u.name);
      const mergeLength = this.users.filter(u => u.can_merge).length;

      if (this.users.length > maxRender) {
        names.push(`+ ${this.users.length - maxRender} more`);
      }

      let mergeStatus = '';

      if (mergeLength > 0) {
        mergeStatus = sprintf(__('%{mergeLength}/%{usersLength} can merge'), {
          mergeLength,
          usersLength: this.sortedAssigness.length,
        });
      } else {
        mergeStatus = __('no one can merge');
      }

      return `${names.join(', ')} (${mergeStatus})`;
    },
    sidebarAvatarCounter() {
      let counter = `+${this.users.length - 1}`;

      if (this.users.length > this.defaultMaxCounter) {
        counter = `${this.defaultMaxCounter}+`;
      }

      return counter;
    },
    moreThanTwoAssigneesCanMerge() {
      const assigneesCount = this.users.length;

      if (this.issuableType !== 'merge_request' || assigneesCount <= 1) {
        return false;
      }

      return this.sortedAssigness.slice(1).some(user => !user.can_merge);
    },
    sortedAssigness() {
      const canMergeUsers = this.users.filter(user => user.can_merge);
      const canNotMergeUsers = this.users.filter(user => !user.can_merge);

      return [...canMergeUsers, ...canNotMergeUsers];
    },
  },
  methods: {
    assignSelf() {
      this.$emit('assign-self');
    },
    toggleShowLess() {
      this.showLess = !this.showLess;
    },
  },
};
</script>

<template>
  <div>
    <div
      v-tooltip
      :class="{ 'multiple-users': hasMoreThanOneAssignee }"
      :title="collapsedTooltipTitle"
      class="sidebar-collapsed-icon sidebar-collapsed-user"
      data-container="body"
      data-placement="left"
      data-boundary="viewport"
    >
      <i v-if="hasNoUsers" :aria-label="__('None')" class="fa fa-user"> </i>
      <collapsed-assignee
        v-for="(user, index) in sortedAssigness"
        :key="user.id"
        :user="user"
        :index="index"
        :length="sortedAssigness.length"
      />
      <button v-if="hasMoreThanTwoAssignees" class="btn-link" type="button">
        <span class="avatar-counter sidebar-avatar-counter"> {{ sidebarAvatarCounter }} </span>
        <i
          v-if="moreThanTwoAssigneesCanMerge"
          aria-hidden="true"
          data-hidden="true"
          class="fa fa-exclamation-triangle merge-icon"
        ></i>
      </button>
    </div>
    <div class="value hide-collapsed">
      <template v-if="hasNoUsers">
        <span class="assign-yourself no-value qa-assign-yourself">
          {{ __('None') }}
          <template v-if="editable">
            -
            <button type="button" class="btn-link" @click="assignSelf">
              {{ __('assign yourself') }}
            </button>
          </template>
        </span>
      </template>
      <template v-else-if="hasOneUser">
        <uncollapsed-single-assignee :user="firstUser" :root-path="rootPath" />
      </template>
      <template v-else>
        <div class="user-list">
          <uncollapsed-assignee
            v-for="(user, index) in sortedAssigness"
            :key="user.id"
            :user="user"
            :index="index"
            :default-render-count="defaultRenderCount"
            :show-less="showLess"
            :root-path="rootPath"
          />
        </div>
        <div v-if="renderShowMoreSection" class="user-list-more">
          <button type="button" class="btn-link" @click="toggleShowLess">
            <template v-if="showLess">
              {{ hiddenAssigneesLabel }}
            </template>
            <template v-else>{{ __('- show less') }}</template>
          </button>
        </div>
      </template>
    </div>
  </div>
</template>
