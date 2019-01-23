<script>
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: { Icon },
  props: {
    addedLines: {
      type: Number,
      required: true,
    },
    removedLines: {
      type: Number,
      required: true,
    },
    diffFilesLength: {
      type: Number,
      required: false,
      default: null,
    },
  }
};
</script>

<template>
  <div class="DiffStats">
    <div v-if="diffFilesLength" class="DiffStats-group filesChanged">
      <icon name="doc-code" /><strong>{{ diffFilesLength }}</strong> Files
    </div>
    <div class="DiffStats-group addedLines">
      <icon name="file-addition" /><strong>{{ addedLines }}</strong>
    </div>
    <div class="DiffStats-group removedLines">
      <icon name="file-deletion" /><strong>{{ removedLines }}</strong>
    </div>
  </div>
</template>
