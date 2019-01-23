<script>
import Icon from '~/vue_shared/components/icon.vue';
export default {
  components: {
    Icon,
  },
  props: {
    commits: {
      type: Array,
      required: true,
      default: () => [],
    },
  },
};
</script>

<template>
  <div>
    <button type="button" class="btn-link btn-blank" data-toggle="dropdown" aria-expanded="false">
      Use an existing commit message
      <icon name="chevron-down" :size="16" aria-hidden="true" class="commits-header-icon" />
    </button>
    <div class="dropdown-menu dropdown-menu-right">
      <div class="dropdown-content">
        <ul>
          <li v-for="commit in commits" :key="commit.sha" @click="$emit('input', commit.title)">
            <div class="dropdown-commit">
              <span class="dropdown-commit-sha">{{ commit.sha }}</span> {{ commit.title }}
            </div>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>
