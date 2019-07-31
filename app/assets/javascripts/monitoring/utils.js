const secondsIn = {
  thirtyMinutes: 60 * 30,
  threeHours: 60 * 60 * 3,
  eightHours: 60 * 60 * 8,
  oneDay: 60 * 60 * 24 * 1,
  threeDays: 60 * 60 * 24 * 3,
  oneWeek: 60 * 60 * 24 * 7 * 1,
};

export const getTimeDiff = timeWindow => {
  const end = Date.now() / 1000; // convert milliseconds to seconds
  const difference = secondsIn(timeWindow) || secondsIn('eightHours');
  const start = end - difference;

  return { start, end };
};

/**
 * This method is used to validate if the graph data format for a chart component
 * that needs a time series as a response from a prometheus query (query_range) is
 * of a valid format or not.
 * @param {Object} graphData  the graph data response from a prometheus request
 * @returns {boolean} whether the graphData format is correct
 */
export const graphDataValidatorForValues = (isValues, graphData) => {
  const responseValueKeyName = isValues ? 'value' : 'values';

  return (
    Array.isArray(graphData.queries) &&
    graphData.queries.filter(query => {
      if (Array.isArray(query.result)) {
        return (
          query.result.filter(res => Array.isArray(res[responseValueKeyName])).length ===
          query.result.length
        );
      }
      return false;
    }).length === graphData.queries.length
  );
};

export default {};
