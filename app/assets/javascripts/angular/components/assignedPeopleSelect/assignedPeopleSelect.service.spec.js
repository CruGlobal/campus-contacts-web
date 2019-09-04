import 'angular-mocks';

// Constants
var assignedPeopleSelectService;

describe('assignedPeopleSelectService', function() {
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

    beforeEach(inject(function(_assignedPeopleSelectService_) {
        assignedPeopleSelectService = _assignedPeopleSelectService_;

        this.person = { id: 123 };
    }));

    describe('isMe', function() {
        it('should check whether the person matches the logged in person', function() {
            expect(assignedPeopleSelectService.isMe(this.person)).toBe(true);
            expect(assignedPeopleSelectService.isMe({ id: 456 })).toBe(false);
        });
    });
});
