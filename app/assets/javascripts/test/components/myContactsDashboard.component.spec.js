(function () {

    'use strict';

    // Constants
    var $controller, myContactsDashboardService, $scope, loggedInPerson;


    describe('myContactsDashboard Components Tests', function () {

        beforeEach(angular.mock.module('missionhubApp'));


        beforeEach(inject(function($rootScope, $componentController, _loggedInPerson_){

            $scope = $rootScope.$new();
            loggedInPerson = _loggedInPerson_;

            spyOn(loggedInPerson, 'person').andReturn({first_name: 'John'});

            $controller = $componentController('myContactsDashboard', {$scope: $scope}, {myBinding: { period: '<',
                'editMode': '<'}}, loggedInPerson);


            myContactsDashboardService = jasmine.createSpyObj('myContactsDashboardService', [
                'loadPeople',
                'loadReports',
                'loadOrganizations'
            ]);


            describe('Components.Controller', function () {

                it('should exist', function () {
                    expect($controller).toBeDefined();
                });

                it('loadPeople should have been called', function () {
                    myContactsDashboardService.loadPeople();
                    expect(myContactsDashboardService.loadPeople).toHaveBeenCalled();
                });

            });

        }));

    });

})();