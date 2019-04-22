<script>
import { GlLineChart } from '@gitlab/ui/dist/charts';
import { debounceByAnimationFrame } from '~/lib/utils/common_utils';
import { chartHeight } from '../../constants';

let debouncedResize;

export default {
  components: {
    GlLineChart,
  },
  inheritAttrs: false,
  props: {
    graphData: {
      type: Object,
      required: true,
      validator(data) {
        return (
          Array.isArray(data.queries) &&
          data.queries.filter(query => {
            if (Array.isArray(query.result)) {
              return (
                query.result.filter(res => Array.isArray(res.values)).length === query.result.length
              );
            }
            return false;
          }).length === data.queries.length
        );
      },
      containerWidth: {
        type: Number,
        required: true,
      },
    },
  },
  data() {
    return {
      width: 0,
      height: chartHeight,
    };
  },
  watch: {
    containerWidth: 'onResize',
  },
  beforeDestroy() {
    window.removeEventListener('resize', debouncedResize);
  },
  created() {
    debouncedResize = debounceByAnimationFrame(this.onResize);
    window.addEventListener('resize', debouncedResize);
  },
  methods: {
    onChartUpdated() {
      // Do something when the chart gets updated or don't
    },
    onResize() {
      const { width } = this.$refs.lineChart.$el.getBoundingClientRect();
      this.width = width;
    },
  },
};
</script>
<template>
  <div class="prometheus-graph col-12 col-lg-6">
    <div class="prometheus-graph-header">
      <h5 ref="graphTitle" class="prometheus-graph-title">{{ graphData.title }}</h5>
      <div ref="graphWidgets" class="prometheus-graph-widgets"><slot></slot></div>
    </div>
    <gl-line-chart
      ref="lineChart"
      v-bind="$attrs"
      :data="chartData"
      :option="chartOptions"
      :width="width"
      :height="height"
      @updated="onChartUpdated"
    />
  </div>
</template>
