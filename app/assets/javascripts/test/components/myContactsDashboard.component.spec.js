(function () {

    'use strict';

    // Constants
    var $controller, myContactsDashboardService, $scope;


    describe('myContactsDashboard Components Tests', function () {

        beforeEach(angular.mock.module('missionhubApp'));


        beforeEach(inject(function($rootScope, $componentController){

            $scope = $rootScope.$new();
            $controller = $componentController('myContactsDashboard', {$scope: $scope}, {myBinding: { period: '<',
                'editMode': '<'}});

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

            it('should exist', function () {
                expect($controller).toBeDefined();
            });

        });

        describe('Components.Controller', function () {
            it('loadMe should have been called', function () {
                myContactsDashboardService.loadMe();
                expect(myContactsDashboardService.loadMe).toHaveBeenCalled();
            });

            it('loadPeople should have been called', function () {
                myContactsDashboardService.loadPeople();
                expect(myContactsDashboardService.loadPeople).toHaveBeenCalled();
            });

        });

    });

})();