import 'angular-mocks';

// Constants
var peopleFiltersPanelService;

describe('peopleFiltersPanelService', function () {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function (_peopleFiltersPanelService_) {
        peopleFiltersPanelService = _peopleFiltersPanelService_;
    }));

    describe('filtersHasActive', function () {
        it('should return true when a search string filter is present', function () {
            expect(peopleFiltersPanelService.filtersHasActive({
                searchString: 'John'
            })).toEqual(true);
        });

        it('should return true when an archived filter is present', function () {
            expect(peopleFiltersPanelService.filtersHasActive({
                includeArchived: true
            })).toEqual(true);
        });

        it('should return true when a label filter is present', function () {
            expect(peopleFiltersPanelService.filtersHasActive({
                labels: { 1: true }
            })).toEqual(true);
        });

        it('should return true when an assigned to filter is present', function () {
            expect(peopleFiltersPanelService.filtersHasActive({
                assignedTos: { 1: true }
            })).toEqual(true);
        });

        it('should return true when a group filter is present', function () {
            expect(peopleFiltersPanelService.filtersHasActive({
                groups: { 1: true }
            })).toEqual(true);
        });

        it('should return false when no filters are present', function () {
            expect(peopleFiltersPanelService.filtersHasActive({})).toEqual(false);

            expect(peopleFiltersPanelService.filtersHasActive({
                searchString: '',
                includeArchived: false,
                labels: {},
                assignedTos: {},
                groups: {}
            })).toEqual(false);
        });
    });
});
