import * as monitorHelper from '~/helpers/monitor_helper';

describe('monitor helper', () => {
  const defaultConfig = { default: true, name: 'default name' };
  const name = 'data name';
  const values = [1, 2, 3];
  const data = [{ metric: { default_name: name }, values }];

  describe('assignDataToSeries', () => {
    const expectedDataSeries = {
      ...defaultConfig,
      data,
    };

    it('adds data to default configuration', () => {
      expect(monitorHelper.assignDataToSeries(defaultConfig, data)).toEqual(expectedDataSeries);
    });

    it('adds name to default configuration', () => {
      expect(monitorHelper.assignDataToSeries(defaultConfig, data, name)).toEqual({
        ...expectedDataSeries,
        name: `${defaultConfig.name}: ${name}`,
      });
    });
  });

  describe('makeDataSeries', () => {
    const expectedDataSeries = [
      {
        ...defaultConfig,
        data: data[0].values,
      },
    ];

    it('converts query results to data series', () => {
      expect(monitorHelper.makeDataSeries([{ metric: {}, values }], defaultConfig)).toEqual(
        expectedDataSeries,
      );
    });

    it('returns an empty array if no query results exist', () => {
      expect(monitorHelper.makeDataSeries([], defaultConfig)).toEqual([]);
    });

    it('handles multi-series query results', () => {
      const expectedData = { ...expectedDataSeries[0], name: 'default name: data name' };

      expect(monitorHelper.makeDataSeries([...data, ...data], defaultConfig)).toEqual([
        expectedData,
        expectedData,
      ]);
    });
  });
});
