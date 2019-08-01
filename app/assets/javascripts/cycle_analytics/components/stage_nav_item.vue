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
  computed: {
    hasValue() {
      return this.value && this.value.length > 0;
    },
  },
};
</script>

<template>
  <li @click="$emit('select')">
    <stage-card-list-item :is-active="isActive">
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
    </stage-card-list-item>
  </li>
</template>
