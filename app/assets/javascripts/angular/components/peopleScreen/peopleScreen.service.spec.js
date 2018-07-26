var peopleScreenService, httpProxy, $rootScope, $q;

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

describe('peopleScreenService', function() {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function(
        _peopleScreenService_,
        _httpProxy_,
        _$rootScope_,
        _$q_,
    ) {
        peopleScreenService = _peopleScreenService_;
        httpProxy = _httpProxy_;
        $rootScope = _$rootScope_;
        $q = _$q_;

        this.orgId = 123;

        // override these to define what will be result of httpProxy
        this.responsePeople = [];
        this.responseTotal = 10;

        spyOn(httpProxy, 'callHttp').and.callFake(() => {
            return $q.resolve({
                data: this.responsePeople,
                meta: { total: this.responseTotal },
            });
        });
    }));

    describe('buildOrderString', function() {
        it('should generate a valid order string', function() {
            expect(
                peopleScreenService.buildOrderString([
                    { field: 'key1', direction: 'asc' },
                    { field: 'key2', direction: 'desc' },
                    { field: 'key3', direction: 'desc' },
                ]),
            ).toBe('key1,-key2,-key3');
        });
    });

    describe('loadOrgPeopleCount', function() {
        it(
            'should load the person count',
            asynchronous(function() {
                this.responseTotal = 5;

                return peopleScreenService
                    .loadOrgPeopleCount(this.orgId)
                    .then(function(personCount) {
                        expect(personCount).toBe(5);
                    });
            }),
        );
    });
});
