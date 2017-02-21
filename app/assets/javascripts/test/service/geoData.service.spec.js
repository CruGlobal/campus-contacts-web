(function () {
    'use strict';

    // Constants
    var geoDataService, $http, $q, $rootScope;

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

    describe('geoDataService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_geoDataService_, _$http_, _$q_, _$rootScope_) {
            geoDataService = _geoDataService_;
            $http = _$http_;
            $q = _$q_;
            $rootScope = _$rootScope_;
        }));

        describe('getCountries', function () {
            it('should return a list of countries', asynchronous(function () {
                spyOn($http, 'get').and.returnValue($q.resolve({
                    data: [
                        {
                            countryName: 'United States',
                            countryShortCode: 'US',
                            regions: [
                                { name: 'Wyoming' },
                                { name: 'Alabama' }
                            ]
                        }, {
                            countryName: 'Canada',
                            countryShortCode: 'CA',
                            regions: [
                                { name: 'Yukon' },
                                { name: 'Alberta' }
                            ]
                        }
                    ]
                }));

                return geoDataService.getCountries().then(function (countries) {
                    expect(countries).toEqual([
                        {
                            name: 'United States',
                            shortCode: 'US',
                            regions: [
                                { name: 'Alabama' },
                                { name: 'Wyoming' }
                            ]
                        }, {
                            name: 'Canada',
                            shortCode: 'CA',
                            regions: [
                                { name: 'Alberta' },
                                { name: 'Yukon' }
                            ]
                        }
                    ]);
                });
            }));
        });
    });
})();
