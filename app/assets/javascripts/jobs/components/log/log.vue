<script>
import LogLine from './line.vue';
import LogLineHeader from './line_header.vue';

export default {
  components: {
    LogLine,
    LogLineHeader,
  },
  props: {
    sections: {
      type: Array,
      required: true,
    },
    jobPath: {
      type: String,
      required: true,
    },
  },
  methods: {
    handleOnClickCollapsibleLine(section) {
      this.$emit('onClickCollapsibleLine', section);
    },
  },
};
</script>
<template>
  <code class="job-log">
    <template v-for="(section, index) in sections">
      <template v-if="section.isHeader">
        <log-line-header
          :key="`collapsible-${index}`"
          :line="section.line"
          :path="jobPath"
          :is-closed="section.isClosed"
          @toggleLine="handleOnClickCollapsibleLine(section)"
        />
        <template v-if="!section.isClosed">
          <log-line v-for="line in section.lines" :key="line.offset" :line="line" :path="jobPath" />
        </template>
      </template>
      <log-line v-else :key="section.offset" :line="section" :path="jobPath" />
    </template>
  </code>
</template>
