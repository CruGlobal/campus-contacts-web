(function () {
    'use strict';

    // Constants
    var groupsService, $q, $rootScope, httpProxy, JsonApiDataStore, _;

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

        beforeEach(inject(function (_groupsService_, _$q_, _$rootScope_, _httpProxy_, _JsonApiDataStore_, ___) {
            var _this = this;

            groupsService = _groupsService_;
            $q = _$q_;
            $rootScope = _$rootScope_;
            httpProxy = _httpProxy_;
            JsonApiDataStore = _JsonApiDataStore_;
            _ = ___;

            function generateMembership (attributes) {
                var membership = new JsonApiDataStore.Model('group_membership', attributes.id);
                membership.setRelationship('person', new JsonApiDataStore.Model('person', attributes.person_id));
                membership.setAttribute('role', attributes.role);
                return membership;
            }

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
            this.group.setRelationship('group_memberships', [
                generateMembership({ id: 11, person_id: 21, role: 'leader' }),
                generateMembership({ id: 12, person_id: 22, role: 'member' }),
                generateMembership({ id: 13, person_id: 23, role: 'leader' })
            ]);

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
                this.organization.groups = [];
                return groupsService.createGroup(this.group).then(function (group) {
                    expect(_this.organization.groups).toEqual([group]);
                });
            }));
        });

        describe('deleteGroup', function () {
            it('should remove the group from the organization', asynchronous(function () {
                var _this = this;
                this.organization.groups = [this.group];
                return groupsService.deleteGroup(this.group).then(function () {
                    expect(_this.organization.groups).toEqual([]);
                });
            }));
        });

        describe('timeToDate', function () {
            it('should convert milliseconds since midnight into a date object', function () {
                // 12:34:56.789
                var date = groupsService.timeToDate(
                    (12 * 60 * 60 * 1000) +
                    (34 * 60 * 1000) +
                    (56 * 1000) +
                    789
                );

                expect(date.getMilliseconds()).toBe(789);
                expect(date.getSeconds()).toBe(56);
                expect(date.getMinutes()).toBe(34);
                expect(date.getHours()).toBe(12);
            });
        });

        describe('dateToTime', function () {
            it('should convert a date object into milliseconds since midnight', function () {
                var date = new Date();
                date.setMilliseconds(789);
                date.setSeconds(56);
                date.setMinutes(34);
                date.setHours(12);

                // 12:34:56.789
                expect(groupsService.dateToTime(date)).toBe(
                    (12 * 60 * 60 * 1000) +
                    (34 * 60 * 1000) +
                    (56 * 1000) +
                    789
                );
            });
        });

        describe('getAllMembers', function () {
            it('should return all the members of a group', function () {
                expect(_.map(groupsService.getAllMembers(this.group), 'id')).toEqual([21, 22, 23]);
            });
        });

        describe('getMembersWithRole', function () {
            it('should return all the members of a group with the specified role', function () {
                expect(_.map(groupsService.getMembersWithRole(this.group, 'leader'), 'id')).toEqual([21, 23]);
            });
        });

        describe('findMember', function () {
            it('should return the membership for the person', function () {
                var membership = this.group.group_memberships[0];
                expect(groupsService.findMember(this.group, membership.person)).toBe(membership);
            });

            it('should return null if the person is not a member', function () {
                expect(groupsService.findMember(this.group, new JsonApiDataStore.Model('person', 123))).toBe(null);
            });
        });

        describe('payloadFromGroup', function () {
            it('should generate a JSON API payload', function () {
                this.people = [
                    new JsonApiDataStore.Model('person', 11),
                    new JsonApiDataStore.Model('person', 12),
                    new JsonApiDataStore.Model('person', 13)
                ];

                var groupMembership1 = new JsonApiDataStore.Model('group_membership', 1);
                groupMembership1.setAttribute('role', 'leader');
                groupMembership1.setRelationship('person', this.people[0]);

                var groupMembership2 = new JsonApiDataStore.Model('group_membership', 2);
                groupMembership2.setAttribute('role', 'member');
                groupMembership2.setRelationship('person', this.people[1]);

                this.group = new JsonApiDataStore.Model('group', 3);
                this.group.setAttribute('name', 'Group');
                this.group.setAttribute('location', 'Place');
                this.group.setAttribute('meets', 'monthly');
                this.group.setAttribute('meeting_day', 1);
                this.group.setAttribute('start_time', 0);
                this.group.setAttribute('end_time', 1);
                this.group.setAttribute('extra_key', 'extra_value'); // attribute that should not be serialized
                this.group.setRelationship('group_memberships', [groupMembership1, groupMembership2]);

                var newLeaders = [this.people[1], this.people[2]];
                expect(groupsService.payloadFromGroup(this.group, newLeaders)).toEqual({
                    data: {
                        type: 'group',
                        id: 3,
                        attributes: {
                            name: 'Group',
                            location: 'Place',
                            meets: 'monthly',
                            meeting_day: 1,
                            start_time: 0,
                            end_time: 1
                        }
                    },
                    included: [
                        // demoted
                        { type: 'group_membership', id: 1, attributes: { role: 'member' } },

                        // promoted
                        { type: 'group_membership', id: 2, attributes: { role: 'leader' } },

                         // created
                        { type: 'group_membership', attributes: { group_id: 3, person_id: 13, role: 'leader' } }
                    ]
                });
            });
        });

        describe('loadMemberships', function () {
            beforeEach(function () {
                this.loaded = {};
                this.unloaded = { _placeHolder: true };
            });

            it('should load the groups and memberships of an organization when a group is unloaded', function () {
                groupsService.loadMemberships({
                    groups: [
                        { group_memberships: [this.loaded] },
                        this.unloaded
                    ]
                });
                expect(httpProxy.callHttp).toHaveBeenCalled();
            });

            it('should load the groups and memberships of an organization when a membership is unloaded', function () {
                groupsService.loadMemberships({
                    groups: [
                        { group_memberships: [this.loaded] },
                        { group_memberships: [this.loaded, this.unloaded] }
                    ]
                });
                expect(httpProxy.callHttp).toHaveBeenCalled();
            });

            it('should do nothing when all groups and memberships are loaded', function () {
                groupsService.loadMemberships({
                    groups: [
                        { group_memberships: [this.loaded, this.loaded] },
                        { group_memberships: [this.loaded, this.loaded] }
                    ]
                });
                expect(httpProxy.callHttp).not.toHaveBeenCalled();
            });
        });

        describe('loadMissingLeaders', function () {
            it('should load all missing leaders across all groups', function () {
                groupsService.loadMissingLeaders({
                    groups: [
                        {
                            group_memberships: [
                                { role: 'member', person: { id: 1, _placeHolder: true } },
                                { role: 'leader', person: { id: 2 } },
                                { role: 'leader', person: { id: 3, _placeHolder: true } }
                            ]
                        }, {
                            group_memberships: [
                                { role: 'leader', person: { id: 4, _placeHolder: true } },
                                { role: 'member', person: { id: 5 } }
                            ]
                        }
                    ]
                });

                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    {
                        include: '',
                        'filters[ids]': '3,4',
                        'page[limit]': 2
                    },
                    null,
                    jasmine.objectContaining({ errorMessage: jasmine.any(String) })
                );
            });

            it('should do nothing when there are no unloaded leaders', function () {
                groupsService.loadMissingLeaders({
                    groups: [
                        {
                            group_memberships: [
                                { role: 'member', person: { id: 1, _placeHolder: true } },
                                { role: 'leader', person: { id: 2 } },
                                { role: 'leader', person: { id: 3 } }
                            ]
                        }, {
                            group_memberships: [
                                { role: 'leader', person: { id: 4 } },
                                { role: 'member', person: { id: 5, _placeHolder: true } }
                            ]
                        }
                    ]
                });

                expect(httpProxy.callHttp).not.toHaveBeenCalled();
            });
        });
    });
})();
