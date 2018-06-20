import 'angular-mocks';

// Constants
var groupMembersModalService, $q, $rootScope, httpProxy, _;

// Add better asynchronous support to a test function
// The test function must return a promise
// The promise will automatically be bound to "done" and the $rootScope will be automatically digested
function asynchronous(fn) {
    return function(done) {
        var returnValue = fn.call(this, done);
        returnValue
            .then(function() {
                done();
            })
            .catch(function(err) {
                done.fail(err);
            });
        $rootScope.$apply();
        return returnValue;
    };
}

describe('groupMembersModalService service', function() {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function(
        _groupMembersModalService_,
        _$q_,
        _$rootScope_,
        _httpProxy_,
        ___,
    ) {
        groupMembersModalService = _groupMembersModalService_;
        $q = _$q_;
        $rootScope = _$rootScope_;
        httpProxy = _httpProxy_;
        _ = ___;

        this.group = {
            id: 1,
            group_memberships: [{ id: 11 }],
        };
    }));

    describe('groupMembersModalService.addMember', function() {
        it(
            'should add the new membership to the group',
            asynchronous(function() {
                spyOn(httpProxy, 'extractModel').and.returnValue({ id: 12 });
                spyOn(httpProxy, 'callHttp').and.returnValue($q.resolve());

                var _this = this;
                var person = { id: 21 };
                return groupMembersModalService
                    .addMember(this.group, person)
                    .then(function() {
                        expect(
                            _.map(_this.group.group_memberships, 'id'),
                        ).toEqual([11, 12]);
                    });
            }),
        );
    });

    describe('groupMembersModalService.removeMember', function() {
        it(
            'should remove the membership from the group',
            asynchronous(function() {
                spyOn(httpProxy, 'callHttp').and.returnValue($q.resolve());

                var _this = this;
                var membership = this.group.group_memberships[0];
                return groupMembersModalService
                    .removeMember(this.group, membership)
                    .then(function() {
                        expect(
                            _.map(_this.group.group_memberships, 'id'),
                        ).toEqual([]);
                    });
            }),
        );
    });
});
