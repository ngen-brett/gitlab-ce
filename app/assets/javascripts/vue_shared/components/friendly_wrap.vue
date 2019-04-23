<script>
import _ from 'underscore';

export default {
  props: {
    text: {
      type: String,
      required: true,
    },
    symbols: {
      type: Array,
      required: false,
      default: () => ['/'],
    },
  },
  computed: {
    displayText() {
      return [...new Set(this.symbols)]
        .map(symbol => symbol.replace(/[-/\\^$*+?.()|[\]{}]/g, '\\$&'))
        .reduce(
          (str, symbol) => str.replace(new RegExp(`(${symbol})`, 'g'), `$1<wbr>`),
          _.escape(this.text),
        );
    },
  },
};
</script>

<template>
  <span class="text-break" v-html="displayText"></span>
</template>
