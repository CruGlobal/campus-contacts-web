(function () {
    'use strict';

    var organizationOverviewPeopleService, httpProxy, $rootScope, $q, _;

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

        beforeEach(inject(function (_organizationOverviewPeopleService_, _httpProxy_, _$rootScope_, _$q_, ___) {
            organizationOverviewPeopleService = _organizationOverviewPeopleService_;
            httpProxy = _httpProxy_;
            $rootScope = _$rootScope_;
            $q = _$q_;
            _ = ___;

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
            spyOn(organizationOverviewPeopleService, 'buildGetParams');
        }));

        describe('loadMoreOrgPeople', function () {
            it('loads first batch of people', asynchronous(function () {
                this.responsePeople = [
                    { id: 1 },
                    { id: 2 },
                    { id: 3 }
                ];
                this.responseTotal = 4;
                var _this = this;

                return organizationOverviewPeopleService.loadMoreOrgPeople(this.orgId, [])
                    .then(function (resp) {
                        var respIds = _.map(resp.people, 'id');
                        expect(respIds).toEqual([1, 2, 3]);
                        expect(resp.loadedAll).toBe(false);
                        expect(organizationOverviewPeopleService.buildGetParams)
                            .toHaveBeenCalledWith(_this.orgId, { limit: 26, offset: 0 }, undefined);
                    });
            }));

            it('loads second batch with more to come', asynchronous(function () {
                var alreadyLoadedPeople = [
                    { id: 1 },
                    { id: 2 },
                    { id: 3 }
                ];
                this.responsePeople = [
                    { id: 3 },
                    { id: 4 },
                    { id: 5 },
                    { id: 6 }
                ];
                this.responseTotal = 7;
                var _this = this;

                return organizationOverviewPeopleService.loadMoreOrgPeople(this.orgId, alreadyLoadedPeople)
                    .then(function (resp) {
                        var respIds = _.map(resp.people, 'id');
                        expect(respIds).toEqual([1, 2, 3, 4, 5, 6]);
                        expect(resp.loadedAll).toBe(false);
                        expect(organizationOverviewPeopleService.buildGetParams)
                            .toHaveBeenCalledWith(_this.orgId, { limit: 26, offset: 2 }, undefined);
                    });
            }));

            it('loads second and final batch', function () {
                var alreadyLoadedPeople = [
                    { id: 1 },
                    { id: 2 }
                ];
                this.responsePeople = [
                    { id: 2 },
                    { id: 3 }
                ];
                this.responseTotal = 3;
                var _this = this;

                return organizationOverviewPeopleService.loadMoreOrgPeople(this.orgId, alreadyLoadedPeople)
                    .then(function (resp) {
                        var respIds = _.map(resp.people, 'id');
                        expect(respIds).toEqual([1, 2, 3]);
                        expect(resp.loadedAll).toBe(true);
                        expect(organizationOverviewPeopleService.buildGetParams)
                            .toHaveBeenCalledWith(_this.orgId, { limit: 26, offset: 1 }, undefined);
                    });
            });
        });

        describe('loadOrgPeopleCount', function () {
            it('should load the person count', asynchronous(function () {
                this.responseTotal = 5;
                var _this = this;

                return organizationOverviewPeopleService.loadOrgPeopleCount(this.orgId).then(function (personCount) {
                    expect(organizationOverviewPeopleService.buildGetParams)
                        .toHaveBeenCalledWith(_this.orgId, { limit: 0 });
                    expect(personCount).toBe(5);
                });
            }));
        });
    });
})();
