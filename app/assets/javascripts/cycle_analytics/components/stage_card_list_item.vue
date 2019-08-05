<script>
export default {
  name: 'StageCardListItem',
  props: {
    isActive: {
      type: Boolean,
      required: true,
    },
  },
};
</script>

<template>
  <div :class="{ active: isActive }" class="stage-nav-item">
    <slot></slot>
  </div>
</template>
