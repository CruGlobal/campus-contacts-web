(function () {

    'use strict';

    // Constants
    var orgSorter, _;

    describe('orgSorter service', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(function () {
            var _this = this;

            // Mock out the loggedInPerson service
            angular.mock.module(function ($provide) {
                $provide.factory('loggedInPerson', function () {
                    return {
                        person: {
                            user: {
                                get organization_order () {
                                    return _this.orgOrder;
                                }
                            }
                        }
                    }
                });
            });
        });

        beforeEach(inject(function (_orgSorter_, ___) {
            orgSorter = _orgSorter_;
            _ = ___;

            // The org order returned by loggedInPerson.person.user.organization_order
            // It be changed by individual tests
            this.orgOrder = null;

            this.orgs = [
                this.org1 = { id: 1, name: 'Alpha', ancestry: null },
                this.org2 = { id: 2, name: 'Charlie', ancestry: '1' },
                this.org3 = { id: 3, name: 'Bravo', ancestry: '1' },
                this.org4 = { id: 4, name: 'Delta', ancestry: null },
                this.org5 = { id: 5, name: 'Echo', ancestry: '4' }
            ];
        }));

        describe('orgSorter.sort', function () {
            it('should sort by ancestry and name with no org order', function () {
                this.orgOrder = null;
                expect(_.map(orgSorter.sort(this.orgs), 'id')).toEqual([3, 2, 5, 1, 4]);
            });

            it('should sort by org order with complete org order', function () {
                this.orgOrder = [2, 5, 3, 1, 4];
                expect(_.map(orgSorter.sort(this.orgs), 'id')).toEqual(this.orgOrder);
            });

            it('should sort by org order then by ancestry and name with incomplete org order', function () {
                this.orgOrder = [2, 5];
                expect(_.map(orgSorter.sort(this.orgs), 'id')).toEqual([2, 5, 3, 1, 4]);
            });
        });

    });
})();
