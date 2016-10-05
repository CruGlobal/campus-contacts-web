(function () {

    'use strict';

    var organizationOverviewService, httpProxy, $rootScope;

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

    describe('organizationOverviewService', function () {

        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_organizationOverviewService_, _httpProxy_, _$rootScope_) {

            organizationOverviewService = _organizationOverviewService_;
            httpProxy = _httpProxy_;
            $rootScope = _$rootScope_;

            this.id = 123;
            this.placeholderRelation = { _placeHolder: true };
            this.loadedRelation = {};

            spyOn(httpProxy, 'callHttp');
        }));

        describe('loadOrgRelations', function () {
            it('loads groups and surveys when they are unloaded', function () {
                organizationOverviewService.loadOrgRelations({
                    id: this.id,
                    groups: [this.placeholderRelation],
                    surveys: [this.placeholderRelation]
                });
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    { include: 'groups,surveys' }
                );
            });

            it('loads nothing when groups and surveys are loaded', function () {
                organizationOverviewService.loadOrgRelations({
                    id: this.id,
                    groups: [this.loadedRelation],
                    surveys: [this.loadedRelation]
                });
                expect(httpProxy.callHttp).not.toHaveBeenCalled();
            });

            it('loads only surveys when groups are loaded', function () {
                organizationOverviewService.loadOrgRelations({
                    id: this.id,
                    groups: [this.loadedRelation],
                    surveys: [this.placeholderRelation]
                });
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    { include: 'surveys' }
                );
            });

            it('loads only groups when groups are partialy loaded and surveys are loaded', function () {
                organizationOverviewService.loadOrgRelations({
                    id: this.id,
                    groups: [this.loadedRelation, this.placeholderRelation],
                    surveys: [this.loadedRelation]
                });
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    { include: 'groups' }
                );
            });
        });
    });

})();
