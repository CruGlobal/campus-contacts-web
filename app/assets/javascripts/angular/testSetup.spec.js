import './main.js';
import angular from 'angular';
import 'angular-mocks';

beforeEach(angular.mock.module('missionhubApp'));

beforeEach(
    angular.mock.module({
        analyticsService: {
            init: jest.fn(),
            track: jest.fn(),
        },
        authenticationService: {
            storeJwtToken: jest.fn(),
            removeAccess: jest.fn(),
            isTokenValid: jest.fn().and.returnValue(false),
        },
    }),
);
