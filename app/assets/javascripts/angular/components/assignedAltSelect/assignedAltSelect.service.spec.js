import 'angular-mocks';

// Constants
var assignedAltSelectService;

describe('assignedAltSelectService', function() {
    beforeEach(function() {
        var _this = this;
        angular.mock.module(function($provide) {
            $provide.factory('loggedInPerson', function() {
                return {
                    get person() {
                        return _this.person;
                    },
                };
            });
        });
    });

    beforeEach(inject(function(_assignedAltSelectService_) {
        assignedAltSelectService = _assignedAltSelectService_;

        this.person = { id: 123 };
    }));

    describe('isMe', function() {
        it('should check whether the person matches the logged in person', function() {
            expect(assignedAltSelectService.isMe(this.person)).toBe(true);
            expect(assignedAltSelectService.isMe({ id: 456 })).toBe(false);
        });
    });
});
