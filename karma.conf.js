/* eslint-env node */

const path = require('path');
const webpackConfig = require('./webpack.config.js')({ test: true });

delete webpackConfig.entry;
delete webpackConfig.devServer;
webpackConfig.devtool = 'inline-source-map';
if (process.env.npm_lifecycle_event !== 'test-debug') {
    webpackConfig.module.rules.push({
        test: /^(?!.*\.(spec|fixture)\.js$).*\.js$/,
        include: path.resolve('app/'),
        loader: 'istanbul-instrumenter-loader',
        query: {
            esModules: true
        }
    });
}

module.exports = function(config) {
    config.set({

        frameworks: ['jasmine'],

        browsers: ['PhantomJS'],

        reporters: ['mocha', 'coverage-istanbul'],

        files: [
            'node_modules/es6-promise/dist/es6-promise.auto.js',
            'app/assets/javascripts/angular/all-tests.spec.js'
        ],

        preprocessors: {
            'app/assets/javascripts/angular/all-tests.spec.js': ['webpack', 'sourcemap']
        },

        webpack: webpackConfig,

        coverageIstanbulReporter: {
            reports: ['lcov'],
            fixWebpackSourcePaths: true
        }
    });
};
