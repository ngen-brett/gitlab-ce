<script>
import { __ } from '~/locale';
import { mapState } from 'vuex';
import { GlLink, GlButton } from '@gitlab/ui';
import { GlAreaChart, GlLineChart, GlChartSeriesLabel } from '@gitlab/ui/dist/charts';
import dateFormat from 'dateformat';
import { debounceByAnimationFrame, roundOffFloat } from '~/lib/utils/common_utils';
import { getSvgIconPathContent } from '~/lib/utils/icon_utils';
import Icon from '~/vue_shared/components/icon.vue';
import { chartHeight, graphTypes, lineTypes, symbolSizes, dateFormats } from '../../constants';
import { makeDataSeries, makeDataSeriesData } from '~/helpers/monitor_helper';
import { graphDataValidatorForValues } from '../../utils';

let debouncedResize;

export default {
  components: {
    // GlAreaChart,
    GlLineChart,
    GlButton,
    GlChartSeriesLabel,
    GlLink,
    Icon,
  },
  inheritAttrs: false,
  props: {
    graphData: {
      type: Object,
      required: true,
      validator: graphDataValidatorForValues.bind(null, false),
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
    projectPath: {
      type: String,
      required: false,
      default: '',
    },
    showBorder: {
      type: Boolean,
      required: false,
      default: false,
    },
    singleEmbed: {
      type: Boolean,
      required: false,
      default: false,
    },
    thresholds: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      tooltip: {
        title: '',
        content: [],
        commitUrl: '',
        isDeployment: false,
        sha: '',
      },
      width: 0,
      height: chartHeight,
      svgs: {},
      primaryColor: null,
    };
  },
  computed: {
    ...mapState('monitoringDashboard', ['exportMetricsToCsvEnabled']),
    minValue() {
      return 0; // TODO Consider negative values in any of the series
    },
    dataSeries() {
      const [metricQuery, upperQuery, lowerQuery] = this.graphData.queries;
      return {
        metric: {
          label: metricQuery.label,
          data: makeDataSeriesData(metricQuery.result),
        },
        upper: {
          label: upperQuery.label,
          data: makeDataSeriesData(upperQuery.result),
        },
        lower: {
          label: lowerQuery.label,
          data: makeDataSeriesData(lowerQuery.result),
        },
      };
    },

    chartData() {
      const { appearance } = this.graphData.queries[0];
      const lineType =
        appearance && appearance.line && appearance.line.type
          ? appearance.line.type
          : lineTypes.default;
      const lineWidth =
        appearance && appearance.line && appearance.line.width ? appearance.line.width : undefined;

      return [
        {
          type: 'line',
          name: this.formatLegendLabel(this.dataSeries.metric),
          data: this.dataSeries.metric.data,
          symbol: 'circle',
          symbolSize: (val, params) => {
            // TODO Move to a separated method
            let dataIndex = params.dataIndex;
            let [, yVal] = this.dataSeries.metric.data[dataIndex];
            let [, yLower] = this.dataSeries.lower.data[dataIndex];
            let [, yUpper] = this.dataSeries.upper.data[dataIndex];

            if (yVal < yLower || yVal > yUpper) {
              return symbolSizes.small / 2; // Big symbol
            }
            return 0.001; // Prevents Error: <path> attribute transform: Expected number, "matrix(NaN,NaN,NaN,NaN ..."
          },
          itemStyle: {
            borderColor: '#BF0000',
            borderWidth: symbolSizes.small / 2,
          },
          lineStyle: {
            type: lineType,
            width: lineWidth,
          },
          showAllSymbol: true,
        },
      ];
    },
    chartOptions() {
      const stackKey = 'normal-band';
      const { appearance } = this.graphData.queries[0];
      const areaStyle = {
        color: this.primaryColor,
        opacity:
          appearance && appearance.area && typeof appearance.area.opacity === 'number'
            ? appearance.area.opacity
            : 0.2, // TODO Magic number
      };

      return {
        xAxis: {
          name: __('Time'),
          type: 'time',
          axisLabel: {
            formatter: date => dateFormat(date, dateFormats.timeOfDay),
          },
          axisPointer: {
            snap: true,
          },
        },
        yAxis: {
          name: this.yAxisLabel,
          axisLabel: {
            formatter: num => roundOffFloat(num, 3).toString(),
          },
        },
        series: [
          {
            name: this.formatLegendLabel(this.dataSeries.lower),
            type: 'line',
            stack: stackKey,
            data: this.dataSeries.lower.data.map(lowerDataPoint => {
              const [xLowerVal, yLowerVal] = lowerDataPoint;
              return [xLowerVal, yLowerVal + this.minValue];
            }),
            lineStyle: {
              normal: {
                opacity: 0,
              },
            },
            symbol: 'none',
          },
          {
            name: this.formatLegendLabel(this.dataSeries.upper),
            type: 'line',
            stack: stackKey,
            data: this.dataSeries.upper.data.map((upperDataPoint, index) => {
              const [xUpperVal, yUpperVal] = upperDataPoint;
              const [, ylowerVal] = this.dataSeries.lower.data[index];
              return [xUpperVal, yUpperVal - this.minValue];
            }),
            lineStyle: {
              normal: {
                opacity: 0,
              },
            },
            areaStyle,
            symbol: 'none',
          },
          this.deploymentSeries,
        ],
        dataZoom: this.dataZoomConfig,
      };
    },
    dataZoomConfig() {
      const handleIcon = this.svgs['scroll-handle'];
      return handleIcon ? { handleIcon } : {};
    },
    earliestDatapoint() {
      let res = this.chartData.reduce((acc, series) => {
        const { data } = series;
        const { length } = data;
        if (!length) {
          return acc;
        }

        const [first] = data[0];
        const [last] = data[length - 1];
        const seriesEarliest = first < last ? first : last;

        return seriesEarliest < acc || acc === null ? seriesEarliest : acc;
      }, null);
      return res;
    },
    isMultiSeries() {
      return this.tooltip.content.length > 1;
    },
    recentDeployments() {
      let res = this.deploymentData.reduce((acc, deployment) => {
        if (deployment.created_at >= this.earliestDatapoint) {
          const { id, created_at, sha, ref, tag } = deployment;
          acc.push({
            id,
            createdAt: created_at,
            sha,
            commitUrl: `${this.projectPath}/commit/${sha}`,
            tag,
            tagUrl: tag ? `${this.tagsPath}/${ref.name}` : null,
            ref: ref.name,
            showDeploymentFlag: false,
          });
        }

        return acc;
      }, []);
      return res;
    },
    deploymentSeries() {
      return {
        type: graphTypes.deploymentData,
        data: this.recentDeployments.map(deployment => [deployment.createdAt, 0]),
        symbol: this.svgs.rocket,
        symbolSize: symbolSizes.default,
        itemStyle: {
          color: this.primaryColor,
        },
      };
    },
    yAxisLabel() {
      return `${this.dataSeries.metric.label}`;
    },
    csvText() {
      const chartData = this.chartData[0].data;
      const header = `timestamp,${this.dataSeries.metric.label}\r\n`; // eslint-disable-line @gitlab/i18n/no-non-i18n-strings
      return chartData.reduce((csv, data) => {
        const row = data.join(',');
        return `${csv}${row}\r\n`;
      }, header);
    },
    downloadLink() {
      const data = new Blob([this.csvText], { type: 'text/plain' });
      return window.URL.createObjectURL(data);
    },
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
    this.setSvg('rocket');
    this.setSvg('scroll-handle');
  },
  methods: {
    formatLegendLabel(query) {
      return `${query.label}`;
    },
    formatTooltipText(params) {
      this.tooltip.title = dateFormat(params.value, dateFormats.default);
      this.tooltip.content = [];
      params.seriesData.forEach(dataPoint => {
        const [xVal, yVal] = dataPoint.value;
        this.tooltip.isDeployment = dataPoint.componentSubType === graphTypes.deploymentData;
        if (this.tooltip.isDeployment) {
          const [deploy] = this.recentDeployments.filter(
            deployment => deployment.createdAt === xVal,
          );
          this.tooltip.sha = deploy.sha.substring(0, 8);
          this.tooltip.commitUrl = deploy.commitUrl;
        } else {
          const { seriesName, color } = dataPoint;
          const value = yVal.toFixed(3);
          this.tooltip.content.push({
            name: seriesName,
            value,
            color,
          });
        }
      });
    },
    setSvg(name) {
      getSvgIconPathContent(name)
        .then(path => {
          if (path) {
            this.$set(this.svgs, name, `path://${path}`);
          }
        })
        .catch(e => {
          // eslint-disable-next-line no-console, @gitlab/i18n/no-non-i18n-strings
          console.error('SVG could not be rendered correctly: ', e);
        });
    },
    onChartUpdated(chart) {
      [this.primaryColor] = chart.getOption().color;
    },
    onResize() {
      if (!this.$refs.chart) return;
      const { width } = this.$refs.chart.$el.getBoundingClientRect();
      this.width = width;
    },
  },
};
</script>

<template>
  <div
    class="prometheus-graph col-12"
    :class="[showBorder ? 'p-2' : 'p-0', { 'col-lg-6': !singleEmbed }]"
  >
    <div :class="{ 'prometheus-graph-embed w-100 p-3': showBorder }">
      <div class="prometheus-graph-header">
        <h5 class="prometheus-graph-title js-graph-title">{{ graphData.title }}</h5>
        <!-- TODO This button is also available in the menu, should it be here? -->
        <gl-button
          :href="downloadLink"
          :title="__('Download CSV')"
          :aria-label="__('Download CSV')"
          style="margin-left: 200px;"
          download="chart_metrics.csv"
        >{{ __('Download CSV') }}</gl-button>
        <div class="prometheus-graph-widgets js-graph-widgets">
          <slot></slot>
        </div>
      </div>

      <gl-line-chart
        ref="chart"
        v-bind="$attrs"
        :data="chartData"
        :option="chartOptions"
        :format-tooltip-text="formatTooltipText"
        :thresholds="thresholds"
        :width="width"
        :height="height"
        @updated="onChartUpdated"
      >
        <template v-if="tooltip.isDeployment">
          <template slot="tooltipTitle">{{ __('Deployed') }}</template>
          <div slot="tooltipContent" class="d-flex align-items-center">
            <icon name="commit" class="mr-2" />
            <gl-link :href="tooltip.commitUrl">{{ tooltip.sha }}</gl-link>
          </div>
        </template>
        <template v-else>
          <template slot="tooltipTitle">
            <div class="text-nowrap">{{ tooltip.title }}</div>
          </template>
          <template slot="tooltipContent">
            <div
              v-for="(content, key) in tooltip.content"
              :key="key"
              class="d-flex justify-content-between"
            >
              <gl-chart-series-label :color="isMultiSeries ? content.color : ''">{{ content.name }}</gl-chart-series-label>
              <div class="prepend-left-32">{{ content.value }}</div>
            </div>
          </template>
        </template>
      </gl-line-chart>
    </div>
  </div>
</template>
