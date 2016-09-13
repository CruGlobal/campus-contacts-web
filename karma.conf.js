// Karma configuration
// Generated on Thu Sep 08 2016 18:14:18 GMT-0500 (CDT)

module.exports = function(config) {
  config.set({

      // base path that will be used to resolve all patterns (eg. files, exclude)
      basePath: '',

      // frameworks to use
      // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
      frameworks: ['jasmine'],

      // list of files / patterns to load in the browser
      files: [
          './node_modules/angular/angular.js',
          './node_modules/angular-animate/angular-animate.js',
          './node_modules/angular-material-icons/angular-material-icons.js',
          './node_modules/angular-mocks/angular-mocks.js',
          './node_modules/jsonapi-datastore/dist/ng-jsonapi-datastore.js',
          './node_modules/angular-environment/src/angular-environment.js',
          './node_modules/angular-ui-sortable/src/sortable.js',
          './node_modules/angulartics/src/angulartics.js',
          './node_modules/angulartics-google-analytics/lib/angulartics-ga.js',
          './vendor/assets/javascripts/i18n.js',
          './node_modules/lscache/lscache.js',
          './app/assets/javascripts/angular/tests/fix-lscache.js',
          './node_modules/angular-mocks/angular-mocks.js',
          './app/assets/javascripts/angular/missionhubApp.module.js',
          './app/assets/javascripts/angular/missionhubApp.config.js',
          './app/assets/javascripts/angular/missionhubApp.constants.js',
          './app/assets/javascripts/angular/missionhubApp.run.js',
          './app/assets/javascripts/angular/services/httpProxy.service.js',
          './app/assets/javascripts/angular/services/test/httpProxy.service.spec.js'
      ],

      // list of files to exclude
      exclude: [
      ],

      // preprocess matching files before serving them to the browser
      // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
      preprocessors: {
      },

      // test results reporter to use
      // possible values: 'dots', 'progress'
      // available reporters: https://npmjs.org/browse/keyword/karma-reporter
      reporters: ['spec'],

      // web server port
      port: 9876,

      // enable / disable colors in the output (reporters and logs)
      colors: true,

      // level of logging
      // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
      logLevel: config.LOG_INFO,

      // enable / disable watching file and executing tests whenever any file changes
      autoWatch: true,

      // start these browsers
      // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
      //We can other browsers later if we intend to test on them as well ['Chrome', 'Firefox', 'IE', 'Safari', 'ChromeCanary']
      browsers: ['Chrome'],

      // Continuous Integration mode
      // if true, Karma captures browsers, runs the tests and exits
      singleRun: false,

      // Concurrency level
      // how many browser should be started simultaneous
      concurrency: Infinity
  })
}
