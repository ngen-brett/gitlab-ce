<script>
import StageCardListItem from './stage_card_list_item.vue';

export default {
  name: 'StageNavItem',
  components: {
    StageCardListItem,
  },
  props: {
    isActive: {
      type: Boolean,
      default: false,
    },
    isUserAllowed: {
      type: Boolean,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      displayMenu: true,
    };
  },
  computed: {
    hasValue() {
      return this.value && this.value.length > 0;
    },
  },
  methods: {
    handleMouseOver() {
      console.log('handleMouseOver', this);
      this.displayMenu = true;
    },
    handleMouseOut() {
      console.log('handleMouseOut', this);
      this.displayMenu = false;
    },
  },
};
</script>

<template>
  <li @click="$emit('select')" @mouseover="handleMouseOver" @mouseout="handleMouseOut">
    <stage-card-list-item :is-active="isActive" :display-menu="true">
      <div class="stage-nav-item-cell stage-name">{{ title }}</div>
      <div class="stage-nav-item-cell stage-median">
        <template v-if="isUserAllowed">
          <span v-if="hasValue">{{ value }}</span>
          <span v-else class="stage-empty">{{ __('Not enough data') }}</span>
        </template>
        <template v-else>
          <span class="not-available">{{ __('Not available') }}</span>
        </template>
      </div>
      <template #dropdown-options>
        <li>
          <button type="button" class="btn-default btn-transparent">
            {{ __('Edit stage') }}
          </button>
        </li>
        <li>
          <button type="button" class="btn-danger danger">
            {{ __('Remove stage') }}
          </button>
        </li>
      </template>
    </stage-card-list-item>
  </li>
</template>
