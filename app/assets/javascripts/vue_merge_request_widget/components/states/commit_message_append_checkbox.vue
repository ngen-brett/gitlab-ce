<script>
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
