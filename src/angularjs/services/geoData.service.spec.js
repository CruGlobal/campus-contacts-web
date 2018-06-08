import 'angular-mocks';

// Constants
var geoDataService;

describe('geoDataService', function() {
  beforeEach(angular.mock.module('missionhubApp'));

  beforeEach(inject(function(_geoDataService_) {
    geoDataService = _geoDataService_;
  }));

  describe('getCountries', function() {
    it('should return a list of countries', function() {
      return geoDataService.getCountries().then(function(countries) {
        expect(countries[234]).toEqual({
          name: 'United States',
          shortCode: 'US',
          regions: jasmine.any(Object),
        });
        expect(countries[234].regions.slice(0, 2)).toEqual([
          {
            name: 'Alabama',
            shortCode: 'AL',
          },
          {
            name: 'Alaska',
            shortCode: 'AK',
          },
        ]);
      });
    });
  });
});
