(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('geoDataService', geoDataService);

    function geoDataService ($http, _) {
        var geoDataUrl = '/assets/country-region-data/data.json';

        return {
            // Return a promise that resolves to the countries list
            getCountries: function () {
                // Cache the response so that the data will only be loaded once
                return $http.get(geoDataUrl, { cache: true }).then(function (res) {
                    var countries = res.data;

                    // Manipulate the data schema
                    return countries.map(function (country) {
                        // Rename the country name and short code fields
                        return {
                            name: country.countryName,
                            shortCode: country.countryShortCode,
                            regions: _.sortBy(country.regions, 'name')
                        };
                    });
                });
            }
        };
    }
})();
