(function () {
    'use strict';

    // Constants
    var assignedSelectService;

    describe('assignedSelectService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(function () {
            var _this = this;
            angular.mock.module(function ($provide) {
                $provide.factory('loggedInPerson', function () {
                    return {
                        get person () {
                            return _this.person;
                        }
                    };
                });
            });
        });

        beforeEach(inject(function (_assignedSelectService_) {
            assignedSelectService = _assignedSelectService_;

            this.person = { id: 123 };
        }));

        describe('isMe', function () {
            it('should check whether the person matches the logged in person', function () {
                expect(assignedSelectService.isMe(this.person)).toBe(true);
                expect(assignedSelectService.isMe({ id: 456 })).toBe(false);
            });
        });
    });
})();
