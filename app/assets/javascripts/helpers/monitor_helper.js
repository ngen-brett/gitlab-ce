export const assignDataToSeries = (defaultConfig, data, name) => {
  const assignee = { data };
  if (name) {
    assignee.name = `${defaultConfig.name}: ${name}`;
  }

  return { ...defaultConfig, ...assignee };
};

export const makeDataSeries = (queryResults, defaultConfig) =>
  !queryResults.length
    ? []
    : queryResults.map(result => {
        const relevantMetric = defaultConfig.name.toLowerCase().replace(' ', '_');

        return assignDataToSeries(defaultConfig, result.values, result.metric[relevantMetric]);
      });
