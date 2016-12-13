(function () {
    'use strict';

    // Constants
    var $controller, myPeopleDashboardService, $scope, loggedInPerson;

    describe('myPeopleDashboard Components Tests', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function ($rootScope, $componentController, _loggedInPerson_) {
            $scope = $rootScope.$new();
            loggedInPerson = _loggedInPerson_;

            spyOn(loggedInPerson, 'person').andReturn({ first_name: 'John' });

            $controller = $componentController(
                'myPeopleDashboard',
                { $scope: $scope },
                { myBinding: { period: '<', editMode: '<' } },
                loggedInPerson
            );

            myPeopleDashboardService = jasmine.createSpyObj('myPeopleDashboardService', [
                'loadPeople',
                'loadReports',
                'loadOrganizations'
            ]);

            describe('Components.Controller', function () {
                it('should exist', function () {
                    expect($controller).toBeDefined();
                });

                it('loadPeople should have been called', function () {
                    myPeopleDashboardService.loadPeople();
                    expect(myPeopleDashboardService.loadPeople).toHaveBeenCalled();
                });
            });
        }));
    });
})();
