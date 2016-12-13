(function () {
    'use strict';

    var organizationOverviewService, httpProxy, $rootScope, $q;
    var organizationOverviewPeopleService, organizationOverviewTeamService; // eslint-disable-line one-var

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

        beforeEach(inject(function (_organizationOverviewService_, _httpProxy_, _$rootScope_, _$q_,
                                    _organizationOverviewPeopleService_, _organizationOverviewTeamService_) {
            organizationOverviewService = _organizationOverviewService_;
            httpProxy = _httpProxy_;
            $rootScope = _$rootScope_;
            $q = _$q_;
            organizationOverviewPeopleService = _organizationOverviewPeopleService_;
            organizationOverviewTeamService = _organizationOverviewTeamService_;

            this.id = 123;
            this.placeholderRelation = { _placeHolder: true };
            this.loadedRelation = {};

            spyOn(httpProxy, 'callHttp');
        }));

        describe('loadOrgRelations', function () {
            it('loads groups and surveys when they are unloaded', function () {
                organizationOverviewService.loadOrgRelations({
                    _type: 'organization',
                    id: this.id,
                    groups: [this.placeholderRelation],
                    surveys: [this.placeholderRelation]
                });
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    { include: 'groups,surveys' },
                    null,
                    undefined
                );
            });

            it('loads nothing when groups and surveys are loaded', function () {
                organizationOverviewService.loadOrgRelations({
                    _type: 'organization',
                    id: this.id,
                    groups: [this.loadedRelation],
                    surveys: [this.loadedRelation]
                });
                expect(httpProxy.callHttp).not.toHaveBeenCalled();
            });

            it('loads only surveys when groups are loaded', function () {
                organizationOverviewService.loadOrgRelations({
                    _type: 'organization',
                    id: this.id,
                    groups: [this.loadedRelation],
                    surveys: [this.placeholderRelation]
                });
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    { include: 'surveys' },
                    null,
                    undefined
                );
            });

            it('loads only groups when groups are partialy loaded and surveys are loaded', function () {
                organizationOverviewService.loadOrgRelations({
                    _type: 'organization',
                    id: this.id,
                    groups: [this.loadedRelation, this.placeholderRelation],
                    surveys: [this.loadedRelation]
                });
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    { include: 'groups' },
                    null,
                    undefined
                );
            });
        });

        describe('loadOrgSuborgs', function () {
            it('should load the org\'s suborgs', function () {
                organizationOverviewService.loadOrgSuborgs({ id: 1 });
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    {
                        'filters[parent_ids]': 1,
                        include: 'groups,surveys'
                    },
                    null,
                    undefined
                );
            });
        });

        describe('getPersonCount', function () {
            it('should load the person count', asynchronous(function () {
                spyOn(organizationOverviewPeopleService, 'loadOrgPeople').and.returnValue(
                    $q.resolve({ meta: { total: 5 } })
                );

                return organizationOverviewService.getPersonCount({ id: 1 }).then(function (personCount) {
                    expect(organizationOverviewPeopleService.loadOrgPeople).toHaveBeenCalledWith(
                        1,
                        { limit: 0, offset: 0 }
                    );
                    expect(personCount).toBe(5);
                });
            }));
        });

        describe('getTeamCount', function () {
            it('should load the team count', asynchronous(function () {
                spyOn(organizationOverviewTeamService, 'loadOrgTeam').and.returnValue(
                    $q.resolve({ meta: { total: 5 } })
                );

                return organizationOverviewService.getTeamCount({ id: 1 }).then(function (personCount) {
                    expect(organizationOverviewTeamService.loadOrgTeam).toHaveBeenCalledWith(
                        1,
                        { limit: 0, offset: 0 }
                    );
                    expect(personCount).toBe(5);
                });
            }));
        });
    });
})();
