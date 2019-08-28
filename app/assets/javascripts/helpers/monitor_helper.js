/* eslint-disable import/prefer-default-export */

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

// TODO Replace into makeDataSeries ?
export const makeDataSeriesData = queryResults => {
  const data = queryResults[0].values
    .map(d => [d[0], d[1]])
    .filter(([, value]) => !Number.isNaN(value));
  if (!data.length) {
    return [];
  }
  return data;
};
