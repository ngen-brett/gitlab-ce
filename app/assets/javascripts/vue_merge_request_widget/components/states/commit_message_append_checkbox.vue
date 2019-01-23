<script>
// This component is created for the further iteration of https://gitlab.com/gitlab-org/gitlab-ce/issues/47149
// It's a checkbox to append a given string (all commit messages in the case of squash commit) to the
// `commit_edit` textarea

export default {
  props: {
    value: {
      type: String,
      required: true,
    },
    label: {
      type: String,
      required: true,
    },
    inputId: {
      type: String,
      required: true,
      default: 'commit-append-checkbox',
    },
    append: {
      type: String,
      required: true,
    },
  },
  methods: {
    handleAppend(isAppended) {
      if (isAppended) {
        this.$emit('input', value + '\n\r' + append);
      } else {
        this.$emit('input', value.replace(`\n\r\${append}`, ''));
      }
    },
  },
};
</script>

<template>
  <label>
    <input :id="inputId" type="checkbox" @change="handleAppend($event.target.checked)" />
    {{ label }}
  </label>
</template>
