(function () {
    'use strict';

    var organizationOverviewSuborgsService, httpProxy, $rootScope, $q;

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

    describe('organizationOverviewSuborgsService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_organizationOverviewSuborgsService_, _httpProxy_, _$rootScope_, _$q_) {
            organizationOverviewSuborgsService = _organizationOverviewSuborgsService_;
            httpProxy = _httpProxy_;
            $rootScope = _$rootScope_;
            $q = _$q_;

            this.orgId = 123;

            // override these to define what will be result of httpProxy
            this.responseOrgs = [];
            this.responseTotal = 10;

            var _this = this;
            spyOn(httpProxy, 'callHttp').and.callFake(function () {
                return $q.resolve({
                    data: _this.responseOrgs,
                    meta: { total: _this.responseTotal }
                });
            });
        }));

        describe('loadOrgSubOrgCount', function () {
            it('should load the sub org count', asynchronous(function () {
                this.responseTotal = 5;

                return organizationOverviewSuborgsService.loadOrgSubOrgCount(this.orgId).then(function (subOrgCount) {
                    expect(httpProxy.callHttp).toHaveBeenCalledWith(
                        'GET',
                        jasmine.any(String),
                        jasmine.objectContaining({ 'page[limit]': 0 }),
                        null,
                        jasmine.objectContaining({ errorMessage: jasmine.any(String) })
                    );

                    expect(subOrgCount).toBe(5);
                });
            }));
        });
    });
})();
