import './main.js';
import angular from 'angular';
import 'angular-mocks';

class OktaAuth {
    constructor(config) {
        this.token = '';
        this.tokenManager = {};
    }
    start() {}
    signOut() {}
}

window.OktaAuth = OktaAuth;

beforeEach(angular.mock.module('campusContactsApp'));

beforeEach(
    angular.mock.module({
        analyticsService: {
            init: jasmine.createSpy('init'),
            track: jasmine.createSpy('track'),
        },
        authenticationService: {
            storeJwtToken: jasmine.createSpy('storeJwtToken'),
            removeAccess: jasmine.createSpy('removeAccess'),
            isTokenValid: jasmine
                .createSpy('isTokenValid')
                .and.returnValue(false),
        },
    }),
);

/* global require */
// require all spec files
const testsContext = require.context('../', true, /\.\/.*\.spec\.js$/);
testsContext.keys().forEach(testsContext);
