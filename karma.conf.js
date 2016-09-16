// Karma configuration
// Generated on Thu Sep 08 2016 18:14:18 GMT-0500 (CDT)

module.exports = function(config) {
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
            './node_modules/jsonapi-datastore/dist/ng-jsonapi-datastore.js',
            './node_modules/angular-environment/src/angular-environment.js',
            './node_modules/angular-ui-sortable/src/sortable.js',
            './node_modules/angulartics/src/angulartics.js',
            './node_modules/angulartics-google-analytics/lib/angulartics-ga.js',
            './vendor/assets/javascripts/i18n.js',
            './node_modules/lscache/lscache.js',
            './app/assets/javascripts/test/patch/fix-lscache.js',
            './node_modules/angular-mocks/angular-mocks.js',
            './app/assets/javascripts/angular/missionhubApp.module.js',
            './app/assets/javascripts/angular/missionhubApp.config.js',
            './app/assets/javascripts/angular/missionhubApp.constants.js',
            './app/assets/javascripts/angular/missionhubApp.run.js',
            './app/assets/javascripts/angular/services/*.js',
            './app/assets/javascripts/angular/components/*.js',
            './app/assets/javascripts/angular/missionhubApi.endpoints.url.js',
            './app/assets/javascripts/test/service/httpProxy.service.spec.js',
            './app/assets/javascripts/test/service/myContactsDashboard.service.spec.js',
            './app/assets/javascripts/test/service/people.service.spec.js',
            './app/assets/javascripts/test/service/organizationPeople.service.spec.js',
            './app/assets/javascripts/test/components/myContactsDashboard.component.spec.js'
        ],

        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['spec'],


        // start these browsers
        // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        //We can other browsers later if we intend to test on them as well ['Chrome', 'Firefox', 'IE', 'Safari', 'ChromeCanary']
        browsers: ['PhantomJS']
    })
}
