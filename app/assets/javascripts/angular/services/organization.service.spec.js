import 'angular-mocks';

// Constants
var organizationService, $rootScope, $q, JsonApiDataStore, _;

// Add better asynchronous support to a test function
// The test function must return a promise
// The promise will automatically be bound to "done" and the $rootScope will be automatically digested
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

describe('organizationService', function() {
    beforeEach(inject(function(
        _organizationService_,
        _$rootScope_,
        _$q_,
        _JsonApiDataStore_,
        ___,
    ) {
        organizationService = _organizationService_;
        $rootScope = _$rootScope_;
        $q = _$q_;
        JsonApiDataStore = _JsonApiDataStore_;
        _ = ___;

        var _this = this;

        this.orgs = {
            1: { id: '1', ancestry: null },
            2: { id: '2', ancestry: '1' },
            3: { id: '3', ancestry: '1/2' },
            5: { id: '5', ancestry: '1/2/3/4' },
        };

        spyOn(JsonApiDataStore.store, 'find').and.callFake(function(
            type,
            orgId,
        ) {
            return _this.orgs[orgId];
        });
    }));

    describe('getOrgHierarchyIds', function() {
        it('should handle null orgs', function() {
            expect(
                organizationService.getOrgHierarchyIds(this.orgs[0]),
            ).toEqual([]);
        });

        it('should handle orgs with no ancestry', function() {
            expect(
                organizationService.getOrgHierarchyIds(this.orgs[1]),
            ).toEqual(['1']);
        });

        it('should handle orgs with ancestry', function() {
            expect(
                organizationService.getOrgHierarchyIds(this.orgs[3]),
            ).toEqual(['1', '2', '3']);
        });
    });

    describe('getOrgHierarchy', function() {
        it(
            'should not load orgs when all orgs are loaded',
            asynchronous(function() {
                spyOn(organizationService, 'loadOrgsById').and.returnValue(
                    $q.resolve([]),
                );
                return organizationService
                    .getOrgHierarchy(this.orgs[3])
                    .then(function(orgs) {
                        expect(_.map(orgs, 'id')).toEqual(['1', '2', '3']);
                        expect(
                            organizationService.loadOrgsById,
                        ).toHaveBeenCalledWith([], jasmine.any(String));
                    });
            }),
        );

        it(
            'should load missing orgs when not all orgs are loaded',
            asynchronous(function() {
                var _this = this;
                spyOn(organizationService, 'loadOrgsById').and.callFake(
                    function() {
                        // Simulate the load of org 4
                        _this.orgs[4] = { id: '4', ancestry: '1/2/3/4' };
                        return $q.resolve();
                    },
                );

                return organizationService
                    .getOrgHierarchy(this.orgs[5])
                    .then(function(orgs) {
                        expect(_.map(orgs, 'id')).toEqual([
                            '1',
                            '2',
                            '3',
                            '4',
                            '5',
                        ]);
                        expect(
                            organizationService.loadOrgsById,
                        ).toHaveBeenCalledWith(['4'], jasmine.any(String));
                    });
            }),
        );

        it(
            'should ignore unloadable orgs',
            asynchronous(function() {
                var _this = this;
                spyOn(organizationService, 'loadOrgsById').and.returnValue(
                    $q.resolve([]),
                );
                return organizationService
                    .getOrgHierarchy(this.orgs[5])
                    .then(function(orgs) {
                        // Should not include org 4
                        expect(_.map(orgs, 'id')).toEqual(['1', '2', '3', '5']);

                        // Should not attempt to reload org 4
                        organizationService.loadOrgsById.calls.reset();
                        organizationService.getOrgHierarchy(_this.orgs[5]);
                        expect(
                            organizationService.loadOrgsById,
                        ).toHaveBeenCalledWith([], jasmine.any(String));
                    });
            }),
        );
    });
});
