(function () {
    'use strict';

    // Constants
    var groupsService, $q, $rootScope, httpProxy, JsonApiDataStore;

    // Add better asynchronous support to a test function
    // The test function must return a promise
    // The promise will automatically be bound to "done" and the $rootScope will be automatically digested
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

    describe('groupsService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_groupsService_, _$q_, _$rootScope_, _httpProxy_, _JsonApiDataStore_) {
            var _this = this;

            groupsService = _groupsService_;
            $q = _$q_;
            $rootScope = _$rootScope_;
            httpProxy = _httpProxy_;
            JsonApiDataStore = _JsonApiDataStore_;

            this.organization = new JsonApiDataStore.Model('organization', 1);
            this.organization.setRelationship('groups', []);

            this.group = new JsonApiDataStore.Model('group');
            this.group.setAttribute('name', 'Test group');
            this.group.setAttribute('location', 'Somwhere great');
            this.group.setAttribute('meets', 'weekly');
            this.group.setAttribute('meeting_day', 'Thursday');
            this.group.setAttribute('start_time', 64800);
            this.group.setAttribute('end_time', 69300);
            this.group.setRelationship('organization', this.organization);

            // Can be changed in individual tests
            this.httpResponse = $q.resolve({
                data: this.group
            });
            spyOn(httpProxy, 'callHttp').and.callFake(function () {
                return _this.httpResponse;
            });
        }));

        describe('createGroup', function () {
            it('should make a network request', function () {
                groupsService.createGroup(this.group);
                expect(httpProxy.callHttp).toHaveBeenCalled();
            });

            it('should return a promise that resolves to the new group', asynchronous(function () {
                var _this = this;
                return groupsService.createGroup(this.group).then(function (group) {
                    expect(group).toBe(_this.group);
                });
            }));

            it('should add the group to the organization', asynchronous(function () {
                var _this = this;
                spyOn(JsonApiDataStore.store, 'find').and.returnValue(this.organization);
                return groupsService.createGroup(this.group).then(function (group) {
                    expect(_this.organization.groups).toEqual(jasmine.arrayContaining([group]));
                });
            }));
        });
    });
})();
