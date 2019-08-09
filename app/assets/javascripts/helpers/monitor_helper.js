/* eslint-disable import/prefer-default-export */

import { __ } from '~/locale';
import dateFormat from 'dateformat';

export const makeDataSeries = (queryResults, defaultConfig) =>
  queryResults.reduce((acc, result) => {
    const data = result.values.filter(([, value]) => !Number.isNaN(value));
    if (!data.length) {
      return acc;
    }
    const relevantMetric = defaultConfig.name.toLowerCase().replace(' ', '_');
    const name = result.metric[relevantMetric];
    const series = { data };
    if (name) {
      series.name = `${defaultConfig.name}: ${name}`;
    }

    return acc.concat({ ...defaultConfig, ...series });
  }, []);

export const makeTimeAxis = axis => {
  const defaultAxis = {
    name: __('Time'),
    type: 'time',
    axisLabel: {
      formatter: date => dateFormat(date, 'h:MM TT'),
    },
    axisPointer: {
      snap: true,
    },
  };
  return { ...defaultAxis, ...axis };
};

export const getLineStyle = (appearance, defaultLineType) => {
  const lineType =
    appearance && appearance.line && appearance.line.type ? appearance.line.type : defaultLineType;
  const lineWidth =
    appearance && appearance.line && appearance.line.width ? appearance.line.width : undefined;
  return {
    type: lineType,
    width: lineWidth,
  };
};
