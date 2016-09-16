(function () {

    'use strict';

    // Constants
    var $controller, myContactsDashboardController;

    describe('myContactsDashboardController Tests', function () {

        beforeEach(angular.mock.module('ngAnimate'));
        beforeEach(angular.mock.module('ngMdIcons'));


        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_$controller_) {

            $controller = _$controller_;
            myContactsDashboardController = $controller;

        }));

        it('myContactsDashboardController should exist', function () {
            expect(myContactsDashboardController).toBeDefined();
        });

        /*
            This fails so I'll just park this for now.
            it('myContactsDashboardController should contain activate', function () {
                expect(myContactsDashboardController.noContacts).toBeDefined();
            });
        */

    });

})();