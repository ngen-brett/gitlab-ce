<script>
import { __ } from "~/locale";
import $ from 'jquery';
import 'select2';

export default {
  name: __('Select2Select'),
  props: {
    options: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    value: {
      type: String,
      required: false,
      default: '',
    },
  },

  mounted() {
    $(this.$refs.dropdownInput)
      .val(this.value)
      .select2(this.options)
      .on('change', event => this.$emit('input', event.target.value));
  },

  beforeDestroy() {
    $(this.$refs.dropdownInput).select2('destroy');
  },
};
</script>

<template>
  <input ref="dropdownInput" type="hidden" />
</template>
