(function () {

    'use strict';

    // Constants
    var organizationService;
    var JsonApiDataStore;

    describe('organizationService', function () {

        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_organizationService_, _JsonApiDataStore_) {

            organizationService = _organizationService_;
            JsonApiDataStore = _JsonApiDataStore_;

            var _this = this;

            this.orgs = {
                1: { id: '1', ancestry: null },
                2: { id: '2', ancestry: '1' },
                3: { id: '3', ancestry: '1/2' },
                5: { id: '5', ancestry: '1/2/3/4' }
            };

            spyOn(JsonApiDataStore.store, 'find').and.callFake(function (type, orgId) {
                return _this.orgs[orgId];
            });

        }));

        describe('getOrgHierarchyIds', function () {
            it('should handle null orgs', function () {
                expect(organizationService.getOrgHierarchyIds(this.orgs[0])).toEqual([]);
            });

            it('should handle orgs with no ancestry', function () {
                expect(organizationService.getOrgHierarchyIds(this.orgs[1])).toEqual(['1']);
            });

            it('should handle orgs with ancestry', function () {
                expect(organizationService.getOrgHierarchyIds(this.orgs[3])).toEqual(['1', '2', '3']);
            });
        });

        describe('getOrgHierarchy', function () {
            it('should return org models', function () {
                expect(organizationService.getOrgHierarchy(this.orgs[3])).toEqual(
                    [this.orgs[1], this.orgs[2], this.orgs[3]]
                );
            });

            it('should handle orgs with holes in the ancestry', function () {
                expect(organizationService.getOrgHierarchy(this.orgs[5])).toEqual([
                    this.orgs[1], this.orgs[2], this.orgs[3], this.orgs[5]
                ]);
            });
        });

    });

})();
