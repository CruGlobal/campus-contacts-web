let peopleScreenService,
    organizationOverviewPeopleService,
    httpProxy,
    $rootScope,
    $q;

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
        _organizationOverviewPeopleService_,
        _httpProxy_,
        _$rootScope_,
        _$q_,
    ) {
        peopleScreenService = _peopleScreenService_;
        organizationOverviewPeopleService = _organizationOverviewPeopleService_;
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

    describe('loadOrgPeopleCount', function() {
        it(
            'should load the person count',
            asynchronous(function() {
                this.responseTotal = 5;

                return peopleScreenService
                    .loadOrgPeopleCount(
                        this.orgId,
                        organizationOverviewPeopleService,
                    )
                    .then(function(personCount) {
                        expect(personCount).toBe(5);
                    });
            }),
        );
    });
});
