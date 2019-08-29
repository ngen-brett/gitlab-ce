<script>
import { __ } from '~/locale';
import { GlLink, GlButton } from '@gitlab/ui';
import { GlLineChart, GlChartSeriesLabel } from '@gitlab/ui/dist/charts';
import dateFormat from 'dateformat';
import { debounceByAnimationFrame, roundOffFloat } from '~/lib/utils/common_utils';
import { getSvgIconPathContent } from '~/lib/utils/icon_utils';
import Icon from '~/vue_shared/components/icon.vue';
import {
  chartHeight,
  graphTypes,
  lineTypes,
  symbolSizes,
  opacityValues,
  dateFormats,
} from '../../constants';
import { makeDataSeries, makeDataSeriesData } from '~/helpers/monitor_helper';
import { graphDataValidatorForValues, getEarliestDatapoint } from '../../utils';

let debouncedResize;

export default {
  components: {
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
    dataSeries() {
      // TODO This hardcodes the chart into 3 series always in the same order. Try to make it configurable ?
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
    yOffset() {
      // in case the area chart must be displayed below 0
      // calculate an offset for the whole chart
      const mins = Object.keys(this.dataSeries).map(seriesName => {
        return this.dataSeries[seriesName].data.reduce((min, datapoint) => {
          const [, yVal] = datapoint;
          return Math.floor(Math.min(min, yVal));
        }, Infinity);
      });
      return -Math.min(...mins);
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
          data: this.dataSeries.metric.data.map(datapoint => {
            const [xVal, yVal] = datapoint;
            return [xVal, yVal + this.yOffset];
          }),
          symbol: 'circle',
          symbolSize: (val, params) => {
            if (this.isDatapointAnomaly(params.dataIndex)) {
              return symbolSizes.anomaly;
            }
            return 0.0001; // 0 causes echarts to throws an error, use small number instead
          },
          itemStyle: {
            color: params => {
              if (this.isDatapointAnomaly(params.dataIndex)) {
                return '#BF0000';
              }
              return this.primaryColor;
            },
          },
          lineStyle: {
            color: this.primaryColor,
            type: lineType,
            width: lineWidth,
          },
        },
      ];
    },
    chartOptions() {
      const stackKey = 'normal-band';
      const { appearance } = this.graphData.queries[0];
      const normalBandAreaStyle = {
        color: this.primaryColor,
        opacity:
          appearance && appearance.area && typeof appearance.area.opacity === 'number'
            ? appearance.area.opacity
            : opacityValues.normalBand, // TODO Magic number
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
            formatter: num => roundOffFloat(num - this.yOffset, 3).toString(),
          },
        },
        series: [
          this.makeNormalBandSeries({
            name: this.formatLegendLabel(this.dataSeries.lower),
            data: this.dataSeries.lower.data.map(lower => {
              const [xLowerVal, yLowerVal] = lower;
              return [xLowerVal, yLowerVal + this.yOffset];
            }),
          }),
          this.makeNormalBandSeries({
            name: this.formatLegendLabel(this.dataSeries.upper),
            data: this.dataSeries.upper.data.map((upper, i) => {
              const [xUpperVal, yUpperVal] = upper;
              const [, yLowerVal] = this.dataSeries.lower.data[i];
              return [xUpperVal, yUpperVal - yLowerVal];
            }),
            areaStyle: normalBandAreaStyle,
          }),
          this.deploymentSeries,
        ],
        dataZoom: this.dataZoomConfig,
      };
    },
    dataZoomConfig() {
      const handleIcon = this.svgs['scroll-handle'];
      return handleIcon ? { handleIcon } : {};
    },
    isMultiSeries() {
      return this.tooltip.content.length > 1;
    },
    recentDeployments() {
      let res = this.deploymentData.reduce((acc, deployment) => {
        if (deployment.created_at >= getEarliestDatapoint(this.chartData)) {
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
      params.seriesData.forEach(datapoint => {
        const [xVal, yVal] = datapoint.value;
        this.tooltip.isDeployment = datapoint.componentSubType === graphTypes.deploymentData;
        if (this.tooltip.isDeployment) {
          const [deploy] = this.recentDeployments.filter(
            deployment => deployment.createdAt === xVal,
          );
          this.tooltip.sha = deploy.sha.substring(0, 8);
          this.tooltip.commitUrl = deploy.commitUrl;
        } else {
          const { seriesName, color } = datapoint;
          const value = (yVal - this.yOffset).toFixed(3);
          this.tooltip.content.push({
            name: seriesName,
            value,
            color,
          });
        }
      });
    },
    isDatapointAnomaly(dataIndex) {
      const [, yVal] = this.dataSeries.metric.data[dataIndex];
      const [, yLower] = this.dataSeries.lower.data[dataIndex];
      const [, yUpper] = this.dataSeries.upper.data[dataIndex];
      return yVal < yLower || yVal > yUpper;
    },
    makeNormalBandSeries(series) {
      return {
        type: 'line',
        stack: 'normal-band-stack',
        lineStyle: {
          color: this.primaryColor,
          opacity: 0,
        },
        color: this.primaryColor, // used in the tooltip
        symbol: 'none',
        ...series,
      };
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
              <gl-chart-series-label :color="isMultiSeries ? content.color : ''">{{
                content.name
              }}</gl-chart-series-label>
              <div class="prepend-left-32">{{ content.value }}</div>
            </div>
          </template>
        </template>
      </gl-line-chart>
    </div>
  </div>
</template>
