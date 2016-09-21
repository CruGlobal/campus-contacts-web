(function () {

    'use strict';

    // Constants
    var $controller, myContactsDashboardService, $scope, loggedInPerson;


    describe('myContactsDashboard Components Tests', function () {

        beforeEach(angular.mock.module('missionhubApp'));


        beforeEach(inject(function($rootScope, $componentController, _loggedInPerson_){

            $scope = $rootScope.$new();
            $controller = $componentController('myContactsDashboard', {$scope: $scope}, {myBinding: { period: '<',
                'editMode': '<'}});
            loggedInPerson = _loggedInPerson_;
            myContactsDashboardService = jasmine.createSpyObj('myContactsDashboardService', [
                'loadMe',
                'loadPeople',
                'loadReports',
                'loadOrganizations'
            ]);
        }));

        beforeEach(inject(function() {

        }));

        describe('Contact Dashboard Component controller', function () {

            xit('should exist', function () {
                expect($controller).toBeDefined();
            });

        });

        describe('Components.Controller', function () {
            xit('loadMe should have been called', function () {
                myContactsDashboardService.loadMe();
                expect(myContactsDashboardService.loadMe).toHaveBeenCalled();
            });

            xit('loadPeople should have been called', function () {
                myContactsDashboardService.loadPeople();
                expect(myContactsDashboardService.loadPeople).toHaveBeenCalled();
            });

        });

    });

})();