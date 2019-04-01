import angular from 'angular';
import 'angular-mocks';

angular.module('missionhubApp', []);
angular.mock.module('missionhubApp');

angular.mock.module({
    analyticsService: {
        init: jest.fn(),
        track: jest.fn(),
    },
    authenticationService: {
        storeJwtToken: jest.fn(),
        removeAccess: jest.fn(),
        isTokenValid: jest.fn().mockReturnValue(false),
    },
});
