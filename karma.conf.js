// Karma configuration
// Generated on Thu Sep 08 2016 18:14:18 GMT-0500 (CDT)

/* eslint-env node */

module.exports = function (config) {
    'use strict';

    config.set({
        // frameworks to use
        // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        frameworks: ['jasmine'],

        // list of files / patterns to load in the browser
        files: [
            './node_modules/angular/angular.js',
            './node_modules/angular-animate/angular-animate.js',
            './node_modules/angular-material-icons/angular-material-icons.js',
            './node_modules/angular-mocks/angular-mocks.js',
            './node_modules/angular-ui-router/release/angular-ui-router.js',
            './node_modules/jsonapi-datastore/dist/ng-jsonapi-datastore.js',
            './node_modules/angular-environment/src/angular-environment.js',
            './node_modules/angular-ui-sortable/src/sortable.js',
            './node_modules/angular-ui-bootstrap/dist/ui-bootstrap.js',
            './node_modules/angulartics/src/angulartics.js',
            './node_modules/angulartics-google-analytics/lib/angulartics-ga.js',
            './node_modules/moment/moment.js',
            './node_modules/angular-moment/angular-moment.js',
            './vendor/assets/javascripts/i18n.js',
            './node_modules/lscache/lscache.js',
            './node_modules/lodash/lodash.js',
            './app/assets/javascripts/test/patch/fix-lscache.js',
            './node_modules/angular-mocks/angular-mocks.js',
            './app/assets/javascripts/angular/missionhubApp.module.js',
            './app/assets/javascripts/angular/missionhubApp.config.js',
            './app/assets/javascripts/angular/missionhubApp.constants.js',
            './app/assets/javascripts/angular/missionhubApp.run.js',
            './app/assets/javascripts/angular/services/*.js',
            './app/assets/javascripts/angular/components/*/*.js',
            './app/assets/javascripts/angular/missionhubApi.endpoints.url.js',
            './app/assets/javascripts/test/**/*.spec.js'
        ],

        preprocessors: {
            './app/assets/javascripts/angular/**/*.js': ['coverage']
        },

        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['spec', 'coverage'],

        coverageReporter: {
            type: 'html',
            dir: 'coverage/',
            file: 'coverage.html'
        },

        // start these browsers
        // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        // We can other browsers later if we intend to test on them as well: ['Chrome', 'Firefox', 'IE', 'Safari',
        // 'ChromeCanary']
        browsers: ['PhantomJS']
    });
};
