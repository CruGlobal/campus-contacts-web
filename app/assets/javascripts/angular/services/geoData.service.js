angular.module('missionhubApp').factory('geoDataService', geoDataService);

function geoDataService(_) {
    return {
        // Return a promise that resolves to the countries list
        getCountries: function() {
            return import(
                // webpackChunkName: "country-region-data"
                'country-region-data'
            ).then(function({ default: countries }) {
                // Manipulate the data schema
                return countries.map(function(country) {
                    // Rename the country name and short code fields
                    return {
                        name: country.countryName,
                        shortCode: country.countryShortCode,
                        regions: _.sortBy(country.regions, 'name'),
                    };
                });
            });
        },
    };
}
