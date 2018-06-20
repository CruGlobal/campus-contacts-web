import 'angular-mocks';

// Constants
var modelsService;

describe('modelsService', function() {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function(_modelsService_) {
        modelsService = _modelsService_;
    }));

    describe('getModelUrl', function() {
        it('should return the URL for models', function() {
            expect(modelsService.getModelUrl({ _type: 'person', id: 1 })).toBe(
                '/people/1',
            );
            expect(
                modelsService.getModelUrl({ _type: 'organization', id: 2 }),
            ).toBe('/organizations/2');
            expect(modelsService.getModelUrl({ _type: 'group', id: 3 })).toBe(
                '/groups/3',
            );
        });

        it('should return undefined for invalid model types', function() {
            expect(
                modelsService.getModelUrl({
                    _type: 'organizational_permission',
                    id: 1,
                }),
            ).toBeUndefined();
        });
    });
});
