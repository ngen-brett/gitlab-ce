<script>
import Icon from '~/vue_shared/components/icon.vue';

export default {
  name: 'StageCardListItem',
  components: {
    Icon,
  },
  props: {
    isActive: {
      type: Boolean,
      required: true,
    },
    displayMenu: {
      type: Boolean,
      required: true,
    },
    // isMenuOpen: {
    //   type: Boolean,
    //   required: true,
    // },
  },
  computed: {
    // displayMenu() {
    //   return false;
    // },
  },
};
</script>

<template>
  <div :class="{ active: isActive }" class="stage-nav-item">
    <slot></slot>
    <div v-show="displayMenu" class="dropdown">
      <button
        type="button"
        title="More actions"
        class="more-actions-toggle btn btn-transparent"
        data-toggle="dropdown"
      >
        <icon css-classes="icon" name="ellipsis_v" />
      </button>
      <ul class="dropdown-menu dropdown-open-left">
        <slot name="dropdown-options"></slot>
      </ul>
    </div>
  </div>
</template>
