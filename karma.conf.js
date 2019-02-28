/* eslint-env node */

const path = require('path');
const webpack = require('webpack');
const {
    entry,
    devServer,
    optimization,
    ...webpackConfig
} = require('./webpack.config.js')({ test: true });

const karmaWebpackConfig = {
    ...webpackConfig,
    devtool: 'inline-source-map',
    module: {
        ...webpackConfig.module,
        rules: [
            ...webpackConfig.module.rules,
            ...(process.env.npm_lifecycle_event !== 'test-debug'
                ? [
                      {
                          test: /^(?!.*\.(spec|fixture)\.js$).*\.js$/,
                          include: path.resolve('app/'),
                          loader: 'istanbul-instrumenter-loader',
                          enforce: 'post',
                          query: {
                              esModules: true,
                          },
                      },
                  ]
                : []),
        ],
    },
    plugins: [
        ...webpackConfig.plugins,
        new webpack.NormalModuleReplacementPlugin(
            /\.(svg|gif|png|jpg|jpeg|(sa|sc|c)ss)$/,
            'node-noop',
        ),
    ],
};

module.exports = function(config) {
    config.set({
        frameworks: ['jasmine'],

        browsers: ['ChromeHeadlessNoSandbox'],
        customLaunchers: {
            ChromeHeadlessNoSandbox: {
                base: 'ChromeHeadless',
                flags: ['--no-sandbox'],
            },
        },

        reporters: ['mocha', 'coverage-istanbul'],

        files: ['app/assets/javascripts/angular/all-tests.spec.js'],

        preprocessors: {
            'app/assets/javascripts/angular/all-tests.spec.js': [
                'webpack',
                'sourcemap',
            ],
        },

        webpack: karmaWebpackConfig,

        coverageIstanbulReporter: {
            reports: ['lcov'],
            fixWebpackSourcePaths: true,
        },
    });
};
