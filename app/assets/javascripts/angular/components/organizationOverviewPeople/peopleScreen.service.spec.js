let organizationOverviewPeopleService;

describe('organizationOverviewPeopleService', function() {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function(
        _peopleScreenService_,
        _organizationOverviewPeopleService_,
    ) {
        organizationOverviewPeopleService = _organizationOverviewPeopleService_;
    }));

    describe('buildOrderString', function() {
        it('should generate a valid order string', function() {
            expect(
                organizationOverviewPeopleService.buildOrderString([
                    { field: 'key1', direction: 'asc' },
                    { field: 'key2', direction: 'desc' },
                    { field: 'key3', direction: 'desc' },
                ]),
            ).toBe('key1,-key2,-key3');
        });
    });
});
