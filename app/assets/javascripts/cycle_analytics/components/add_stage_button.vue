<script>
export default {
  props: {},
};
</script>
<template>
  <li class="stage-nav-item stage-ghost rounded" @click="$emit('showform')">
    {{ s__('CustomCycleAnalytics|Add a stage') }}
  </li>
</template>
