(function () {

    'use strict';

    // Constants
    var myContactsDashboardService, httpProxy, apiEndPoint;

    describe('myContactsDashboardService Tests', function () {

        beforeEach(angular.mock.module('ngAnimate'));
        beforeEach(angular.mock.module('ngMdIcons'));


        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function ($q, $log, _myContactsDashboardService_, _httpProxy_, _apiEndPoint_) {

            httpProxy = _httpProxy_;
            myContactsDashboardService = _myContactsDashboardService_;
            apiEndPoint = _apiEndPoint_;

            spyOn(myContactsDashboardService, 'loadOrganizations').and.callFake( function () {
                var deferred = $q.defer();
                deferred.resolve('success');
                return deferred.promise;
            });

            spyOn(myContactsDashboardService, 'loadPeople').and.callFake( function () {
                var deferred = $q.defer();
                deferred.resolve('success');
                return deferred.promise;
            });

            spyOn(myContactsDashboardService, 'loadPeopleReports').and.callFake( function () {
                var deferred = $q.defer();
                deferred.resolve('success');
                return deferred.promise;
            });

            spyOn(myContactsDashboardService, 'loadOrganizationReports').and.callFake( function () {
                var deferred = $q.defer();
                deferred.resolve('success');
                return deferred.promise;
            });

        }));

        it('myContactsDashboardService should exist', function () {
            expect(myContactsDashboardService).toBeDefined();
        });

        it('myContactsDashboardService should contain loadPeople', function () {
            expect(myContactsDashboardService.loadPeople).toBeDefined();
        });

        it('myContactsDashboardService should contain loadPeopleReports', function () {
            expect(myContactsDashboardService.loadPeopleReports).toBeDefined();
        });

        it('myContactsDashboardService should contain loadOrganizationReports', function () {
            expect(myContactsDashboardService.loadOrganizationReports).toBeDefined();
        });

        it('myContactsDashboardService should contain loadOrganizations', function () {
            expect(myContactsDashboardService.loadOrganizations).toBeDefined();
        });

        it('myContactsDashboardService should contain updateUserPreference', function () {
            expect(myContactsDashboardService.updateUserPreference).toBeDefined();
        });

        it('should load organizations', function () {

            var request  = myContactsDashboardService.loadOrganizations();

            var response = request.then( function (response) {
                return response;
            });

            var expectedResponse = request.then( function (response) {
                return response;
            });

            expect(response).toEqual(expectedResponse);

        });

        it('should load people', function () {

            var request  = myContactsDashboardService.loadPeople();

            var response = request.then( function (response) {
                return response;
            });

            var expectedResponse = request.then( function (response) {
                return response;
            });

            expect(response).toEqual(expectedResponse);

        });

        it('should load people Reports', function () {

            var model = {
                period: 10,
                organization_ids: 12,
                people_ids: 14
            };
            var request  = myContactsDashboardService.loadPeopleReports(model);

            var response = request.then( function (response) {
                return response;
            });

            var expectedResponse = request.then( function (response) {
                return response;
            });

            expect(response).toEqual(expectedResponse);

        });

        it('should load organization Reports', function () {

            var model = {
                period: 10,
                organization_ids: 12
            };
            var request  = myContactsDashboardService.loadOrganizationReports(model);

            var response = request.then( function( response) {
                return response;
            });

            var expectedResponse = request.then( function (response) {
                return response;
            });

            expect(response).toEqual(expectedResponse);

        });

    });

})();
