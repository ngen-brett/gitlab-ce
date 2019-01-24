<script>
import { GlAreaChart } from '@gitlab/ui';
import dateFormat from 'dateformat';
import { debounceByAnimationFrame, getSvgIconPath } from '../../../helpers/monitor_helper';

export default {
  components: {
    GlAreaChart,
  },
  inheritAttrs: false,
  props: {
    graphData: {
      type: Object,
      required: true,
      validator(data) {
        return (
          data.queries &&
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
    },
    containerWidth: {
      type: Number,
      required: true,
    },
    deploymentData: {
      type: Array,
      required: false,
      default: () => [],
    },
    alertData: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      width: 0,
      height: 0,
      debouncedResize: debounceByAnimationFrame(this.onResize),
    };
  },
  computed: {
    chartData() {
      return this.graphData.queries.reduce((accumulator, query) => {
        accumulator[query.unit] = query.result.reduce((acc, res) => acc.concat(res.values), []);
        return accumulator;
      }, {});
    },
    chartOptions() {
      return {
        xAxis: {
          name: 'Time',
          type: 'time',
          axisLabel: {
            formatter: date => dateFormat(date, 'h:MM TT'),
          },
          axisPointer: {
            snap: true,
          },
          nameTextStyle: {
            padding: [18, 0, 0, 0],
          },
        },
        yAxis: {
          name: this.yAxisLabel,
          axisLabel: {
            formatter: value => value.toFixed(3),
          },
          nameTextStyle: {
            padding: [0, 0, 36, 0],
          },
        },
        legend: {
          formatter: this.xAxisLabel,
        },
        series: this.scatterSeries,
      };
    },
    earliestDatapoint() {
      return Object.values(this.chartData).reduce((acc, data) => {
        const [[timestamp]] = data.sort(([a], [b]) => {
          if (a < b) {
            return -1;
          }
          return a > b ? 1 : 0;
        });

        return timestamp < acc || acc === null ? timestamp : acc;
      }, null);
    },
    recentDeployments() {
      return this.deploymentData
        ? this.deploymentData.reduce((acc, deployment) => {
            if (deployment.created_at >= this.earliestDatapoint) {
              acc.push({
                id: deployment.id,
                createdAt: deployment.created_at,
                sha: deployment.sha,
                commitUrl: `${this.projectPath}/commit/${deployment.sha}`,
                tag: deployment.tag,
                tagUrl: deployment.tag ? `${this.tagsPath}/${deployment.ref.name}` : null,
                ref: deployment.ref.name,
                showDeploymentFlag: false,
              });
            }

            return acc;
          }, [])
        : [];
    },
    scatterSeries() {
      return {
        type: 'scatter',
        data: this.recentDeployments.map(deployment => [deployment.createdAt, 0]),
        symbol: `path://${scatterSymbol}`,
        symbolSize: 14,
      };
    },
    xAxisLabel() {
      return this.graphData.queries.map(query => query.label).join(', ');
    },
    yAxisLabel() {
      const [query] = this.graphData.queries;
      return `${this.graphData.y_label} (${query.unit})`;
    },
  },
  watch: {
    containerWidth() {
      setTimeout(this.onResize, 150);
    },
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.debouncedResize);
  },
  created() {
    window.addEventListener('resize', this.debouncedResize);
  },
  methods: {
    formatTooltipText(params) {
      const [date, value] = params;
      return [dateFormat(date, 'dd mmm yyyy, h:MMtt'), value.toFixed(3)];
    },
    onResize() {
      const { width, height } = this.$refs.areaChart.$el.getBoundingClientRect();
      this.width = width;
      this.height = height;
    },
  },
};
</script>

<template>
  <div class="prometheus-graph col-12 col-lg-6">
    <div class="prometheus-graph-header">
      <h5 class="prometheus-graph-title">{{ graphData.title }}</h5>
      <div class="prometheus-graph-widgets"><slot></slot></div>
    </div>
    <gl-area-chart
      ref="areaChart"
      v-bind="$attrs"
      :data="chartData"
      :option="chartOptions"
      :format-tooltip-text="formatTooltipText"
      :thresholds="alertData"
      :width="width"
      :height="height"
    />
  </div>
</template>
