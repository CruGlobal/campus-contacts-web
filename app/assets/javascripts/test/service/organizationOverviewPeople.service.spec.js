(function () {
    'use strict';

    var organizationOverviewPeopleService, httpProxy, $rootScope, $q;

    function asynchronous (fn) {
        return function (done) {
            var returnValue = fn.call(this, done);
            returnValue.then(function () {
                done();
            }).catch(function (err) {
                done.fail(err);
            });
            $rootScope.$apply();
            return returnValue;
        };
    }

    describe('organizationOverviewPeopleService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_organizationOverviewPeopleService_, _httpProxy_, _$rootScope_, _$q_) {
            organizationOverviewPeopleService = _organizationOverviewPeopleService_;
            httpProxy = _httpProxy_;
            $rootScope = _$rootScope_;
            $q = _$q_;

            this.orgId = 123;

            // override these to define what will be result of httpProxy
            this.responsePeople = [];
            this.responseTotal = 10;

            var _this = this;
            spyOn(httpProxy, 'callHttp').and.callFake(function () {
                return $q.resolve({
                    data: _this.responsePeople,
                    meta: { total: _this.responseTotal }
                });
            });
        }));

        describe('loadOrgPeopleCount', function () {
            it('should load the person count', asynchronous(function () {
                this.responseTotal = 5;

                return organizationOverviewPeopleService.loadOrgPeopleCount(this.orgId).then(function (personCount) {
                    expect(personCount).toBe(5);
                });
            }));
        });
    });
})();
