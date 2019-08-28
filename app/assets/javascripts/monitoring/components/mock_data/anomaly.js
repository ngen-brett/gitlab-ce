// TODO Move this data to be used only by specs

export const graphDataPrometheusQueryAnomaly = {
  title: 'Requests Per Second (Mock)',
  type: 'anomaly-chart',
  weight: 3,
  metrics: [
    {
      id: 'metric',
      query_range: 'MOCK_PROMETHEUS_METRIC_QUERY_RANGE',
      unit: 'RPS',
      label: 'Metrics RPS',
      metric_id: 90,
      prometheus_endpoint_path: 'MOCK_METRIC_PEP',
    },
    {
      id: 'upper',
      query_range: '...',
      unit: 'RPS',
      label: 'Upper Limit Metrics RPS',
      metric_id: 91,
      prometheus_endpoint_path: 'MOCK_UPPER_PEP',
    },
    {
      id: 'lower',
      query_range: '...',
      unit: 'RPS',
      label: 'Lower Limit Metrics RPS',
      metric_id: 92,
      prometheus_endpoint_path: 'MOCK_LOWER_PEP',
    },
  ],
  queries: [
    {
      id: 'metric',
      query_range: '...',
      unit: 'RPS',
      label: 'Metrics RPS',
      metric_id: 90, // HACK
      prometheus_endpoint_path: '...',
      result: [
        {
          metric: {},
          values: [
            [1566241200, '9.202951259932304'],
            [1566244800, '9.626646637028491'],
            [1566248400, '9.683722070709871'],
            [1566252000, '8.54032973516345'],
            [1566255600, '6.950379838087604'],
            [1566259200, '7.5688769983604125'],
            [1566262800, '6.990011048082363'],
            [1566266400, '40.491832869522494'],
            [1566270000, '-27.139642426738163'],
            [1566273600, '6.6433333333479645'],
          ],
        },
      ],
    },
    {
      id: 'upper',
      query_range: '...',
      unit: 'RPS',
      label: 'Upper Limit Metrics RPS',
      metric_id: 91,
      prometheus_endpoint_path: '...',
      result: [
        {
          metric: {},
          values: [
            [1566241200, '32.123566740178525'],
            [1566244800, '32.102044712971825'],
            [1566248400, '32.04495517113375'],
            [1566252000, '31.981461939338814'],
            [1566255600, '31.931359768084796'],
            [1566259200, '31.88374783851358'],
            [1566262800, '31.884392904733893'],
            [1566266400, '31.596452983561854'],
            [1566270000, '31.13827118027419'],
            [1566273600, '31.042810714167913'],
          ],
        },
      ],
    },
    {
      id: 'lower',
      query_range: '...',
      unit: 'RPS',
      label: 'Lower Limit Metrics RPS',
      metric_id: 92,
      prometheus_endpoint_path: '...',
      result: [
        {
          metric: {},
          values: [
            [1566241200, '4.1'],
            [1566244800, '4.2'],
            [1566248400, '4.3'],
            [1566252000, '4.1'],
            [1566255600, '3'],
            [1566259200, '2'],
            [1566262800, '0'],
            [1566266400, '-20'],
            [1566270000, '0'],
            [1566273600, '0'],
          ],
        },
      ],
    },
  ],
};

export const anomalyDeploymentData = [
  {
    id: 111,
    iid: 3,
    sha: 'f5bcd1d9dac6fa4137e2510b9ccd134ef2e84187',
    commitUrl:
      'http://test.host/frontend-fixtures/environments-project/commit/f5bcd1d9dac6fa4137e2510b9ccd134ef2e84187',
    ref: {
      name: 'master',
    },
    created_at: '2019-08-19T22:00:00.000Z',
    deployed_at: '2019-08-19T22:01:00.000Z',
    tag: false,
    tagUrl: 'http://test.host/frontend-fixtures/environments-project/tags/false',
    'last?': true,
  },
  {
    id: 110,
    iid: 2,
    sha: 'f5bcd1d9dac6fa4137e2510b9ccd134ef2e84187',
    commitUrl:
      'http://test.host/frontend-fixtures/environments-project/commit/f5bcd1d9dac6fa4137e2510b9ccd134ef2e84187',
    ref: {
      name: 'master',
    },
    created_at: '2019-08-19T23:00:00.000Z',
    deployed_at: '2019-08-19T23:00:00.000Z',
    tag: false,
    tagUrl: 'http://test.host/frontend-fixtures/environments-project/tags/false',
    'last?': false,
  },
];

export default { graphDataPrometheusQueryAnomaly, anomalyDeploymentData };
