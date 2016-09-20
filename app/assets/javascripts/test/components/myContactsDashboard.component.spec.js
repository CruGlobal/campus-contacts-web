(function () {

    'use strict';

    // Constants
    var $controller, myContactsDashboardService, $scope;

    describe('myContactsDashboardController Tests', function () {

        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(function () {
            myContactsDashboardService = jasmine.createSpyObj('myContactsDashboardService', [
                'loadMe'
            ]);

            module(function ($provide) {
                $provide.value('myContactsDashboardService', myContactsDashboardService);
            });
        });

        beforeEach(inject(function(_$controller_, $rootScope) {
            $scope = $rootScope.$new();

            $controller = _$controller_('myContactsDashboardController', {
                $scope: $scope
            });
        }));

        describe('Contact Dashboard Controller', function () {

            it('myContactsDashboardController should exist', function () {
                expect($controller).toBeDefined();
            });

        });

    });

})();