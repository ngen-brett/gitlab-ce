const path = require('path');
const baseConfig = require('./webpack.config.base.js');
const ROOT_PATH = path.resolve(__dirname, '..');
const CACHE_PATH = process.env.WEBPACK_CACHE_PATH || path.join(ROOT_PATH, 'tmp/cache');


const visualReviewToolbarConfig = {
  ...baseConfig,

  name: 'visual_review_toolbar',

  entry: './visual_review_toolbar',

  output: {
    ...baseConfig.output,
    filename: 'visual_review_toolbar.js',
    library: 'VisualReviewToolbar',
    libraryTarget: 'var',
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        loader: 'babel-loader',
        options: {
          cacheDirectory: path.join(CACHE_PATH, 'babel-loader'),
        },
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },

  plugins: [...baseConfig.plugins],
};

module.exports = visualReviewToolbarConfig;
