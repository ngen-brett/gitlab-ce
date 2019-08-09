import { shallowMount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';
import { GlLineChart, GlChartSeriesLabel } from '@gitlab/ui/dist/charts';
import { shallowWrapperContainsSlotText } from '../../../helpers/vue_test_utils_helper';
import { getSvgIconPathContent } from '~/lib/utils/icon_utils';
import Line from '~/monitoring/components/charts/line.vue';
import { createStore } from '~/monitoring/stores';
import * as types from '~/monitoring/stores/mutation_types';
import { TEST_HOST } from 'helpers/test_constants';
import MonitoringMock, { deploymentData } from '../../../../javascripts/monitoring/mock_data.js'; // TODO Decide if copying the mock_data is better

jest.mock('~/lib/utils/icon_utils');

describe('Area component', () => {
  const mockSha = 'mockSha';
  const mockWidgets = 'mockWidgets';
  const mockSvgPathContent = 'mockSvgPathContent';
  const projectPath = `${TEST_HOST}/path/to/project`;
  const commitUrl = `${projectPath}/commit/${mockSha}`;
  let mockGraphData;
  let lineChart;

  beforeEach(() => {
    const store = createStore();

    store.commit(`monitoringDashboard/${types.RECEIVE_METRICS_DATA_SUCCESS}`, MonitoringMock.data);
    store.commit(`monitoringDashboard/${types.RECEIVE_DEPLOYMENTS_DATA_SUCCESS}`, deploymentData);

    [mockGraphData] = store.state.monitoringDashboard.groups[0].metrics;

    getSvgIconPathContent.mockResolvedValue('mockSvgPathContent');

    lineChart = shallowMount(Line, {
      propsData: {
        graphData: mockGraphData,
        containerWidth: 0,
        deploymentData: store.state.monitoringDashboard.deploymentData,
        projectPath,
      },
      slots: {
        default: mockWidgets,
      },
    });
  });

  afterEach(() => {
    lineChart.destroy();
  });

  it('renders chart title', () => {
    expect(lineChart.find({ ref: 'graphTitle' }).text()).toBe(mockGraphData.title);
  });

  it('contains graph widgets from slot', () => {
    expect(lineChart.find({ ref: 'graphWidgets' }).text()).toBe(mockWidgets);
  });

  describe('wrapped components', () => {
    describe('GitLab UI line chart', () => {
      let glLineChart;

      beforeEach(() => {
        glLineChart = lineChart.find(GlLineChart);
      });

      it('is a Vue instance', () => {
        expect(glLineChart.isVueInstance()).toBe(true);
      });

      it('receives data properties needed for proper chart render', () => {
        const props = glLineChart.props();

        expect(props.data).toBe(lineChart.vm.chartData);
        expect(props.option).toBe(lineChart.vm.chartOptions);
        expect(props.formatTooltipText).toBe(lineChart.vm.formatTooltipText);
        expect(props.thresholds).toBe(lineChart.vm.thresholds);
      });

      it('recieves a tooltip title', () => {
        const mockTitle = 'mockTitle';
        lineChart.vm.tooltip.title = mockTitle;

        expect(shallowWrapperContainsSlotText(glLineChart, 'tooltipTitle', mockTitle)).toBe(true);
      });

      describe('when tooltip is showing deployment data', () => {
        beforeEach(() => {
          lineChart.vm.tooltip.isDeployment = true;
        });

        it('uses deployment title', () => {
          expect(shallowWrapperContainsSlotText(glLineChart, 'tooltipTitle', 'Deployed')).toBe(
            true,
          );
        });

        it('renders clickable commit sha in tooltip content', () => {
          lineChart.vm.tooltip.sha = mockSha;
          lineChart.vm.tooltip.commitUrl = commitUrl;

          const commitLink = lineChart.find(GlLink);

          expect(shallowWrapperContainsSlotText(commitLink, 'default', mockSha)).toBe(true);
          expect(commitLink.attributes('href')).toEqual(commitUrl);
        });
      });
    });
  });

  describe('methods', () => {
    describe('formatTooltipText', () => {
      const mockDate = deploymentData[0].created_at;
      const generateSeriesData = type => ({
        seriesData: [
          {
            seriesName: lineChart.vm.chartData[0].name,
            componentSubType: type,
            value: [mockDate, 5.55555],
            seriesIndex: 0,
          },
        ],
        value: mockDate,
      });

      describe('when series is of line type', () => {
        beforeEach(() => {
          lineChart.vm.formatTooltipText(generateSeriesData('line'));
        });

        it('formats tooltip title', () => {
          expect(lineChart.vm.tooltip.title).toBe('31 May 2017, 9:23PM');
        });

        it('formats tooltip content', () => {
          const name = 'Core Usage';
          const value = '5.556';
          const seriesLabel = lineChart.find(GlChartSeriesLabel);

          expect(seriesLabel.vm.color).toBe('');
          expect(shallowWrapperContainsSlotText(seriesLabel, 'default', name)).toBe(true);
          expect(lineChart.vm.tooltip.content).toEqual([{ name, value, color: undefined }]);
          // expect(
          //   shallowWrapperContainsSlotText(lineChart.find(GlAreaChart), 'tooltipContent', value),
          // ).toBe(true);
        });
      });

      describe('when series is of scatter type', () => {
        beforeEach(() => {
          lineChart.vm.formatTooltipText(generateSeriesData('scatter'));
        });

        it('formats tooltip title', () => {
          expect(lineChart.vm.tooltip.title).toBe('31 May 2017, 9:23PM');
        });

        it('formats tooltip sha', () => {
          expect(lineChart.vm.tooltip.sha).toBe('f5bcd1d9');
        });
      });
    });

    describe('setSvg', () => {
      const mockSvgName = 'mockSvgName';

      beforeEach(() => {
        lineChart.vm.setSvg(mockSvgName);
      });

      it('gets svg path content', () => {
        expect(getSvgIconPathContent).toHaveBeenCalledWith(mockSvgName);
      });

      it('sets svg path content', done => {
        lineChart.vm.$nextTick(() => {
          expect(lineChart.vm.svgs[mockSvgName]).toBe(`path://${mockSvgPathContent}`);
          done();
        });
      });
    });

    describe('onChartUpdated', () => {
      beforeEach(() => {
        const chart = {
          getOption() { 
            return {color : ['red']}
          }
        }
        lineChart.vm.onChartUpdated(chart)
      });

      it('sets primary color', () => {
        expect(lineChart.vm.primaryColor).toBe('red');
      });
    });

    describe('onResize', () => {
      const mockWidth = 233;

      beforeEach(() => {
        jest.spyOn(Element.prototype, 'getBoundingClientRect').mockReturnValue({
          width: mockWidth,
        });
        lineChart.vm.onResize();
      });

      it('sets area chart width', () => {
        expect(lineChart.vm.width).toBe(mockWidth);
      });
    });
  });

  describe('computed', () => {
    describe('chartData', () => {
      let chartData;
      const seriesData = () => chartData[0];

      beforeEach(() => {
        ({ chartData } = lineChart.vm);
      });

      it('utilizes all data points', () => {
        expect(chartData.length).toBe(1);
        expect(seriesData().data.length).toBe(297);
      });

      it('creates valid data', () => {
        const { data } = seriesData();

        expect(
          data.filter(([time, value]) => new Date(time).getTime() > 0 && typeof value === 'number')
            .length,
        ).toBe(data.length);
      });

      it('formats line width correctly', () => {
        expect(chartData[0].lineStyle.width).toBe(2);
      });
    });

    describe('chartOptions', () => {
      describe('yAxis formatter', () => {
        let format;

        beforeEach(() => {
          format = lineChart.vm.chartOptions.yAxis.axisLabel.formatter;
        });

        it('rounds to 3 decimal places', () => {
          expect(format(0.88888)).toBe('0.889');
        });
      });
    });

    describe('scatterSeries', () => {
      it('utilizes deployment data', () => {
        expect(lineChart.vm.scatterSeries.data).toEqual([
          ['2017-05-31T21:23:37.881Z', 0],
          ['2017-05-30T20:08:04.629Z', 0],
          ['2017-05-30T17:42:38.409Z', 0],
        ]);
      });
    });

    describe('yAxisLabel', () => {
      it('constructs a label for the chart y-axis', () => {
        expect(lineChart.vm.yAxisLabel).toBe('CPU');
      });
    });
  });
});
