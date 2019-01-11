import './main.js';
import angular from 'angular';
import 'angular-mocks';

beforeEach(angular.mock.module('missionhubApp'));

beforeEach(
    angular.mock.module({
        analyticsService: {
            init: jasmine.createSpy('init'),
            track: jasmine.createSpy('track'),
        },
    }),
);

/* global require */
// require all spec files
const testsContext = require.context('../', true, /\.\/.*\.spec\.js$/);
testsContext.keys().forEach(testsContext);
