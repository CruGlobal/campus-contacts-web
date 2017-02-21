(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('editAddressService', editAddressService);

    function editAddressService (geoDataService, JsonApiDataStore, _) {
        var editAddressService = {
            // Return an array of valid address types
            getAddressTypes: function () {
                return ['current', 'permanent', 'emergency1', 'emergency2'];
            },

            // Return a boolean indicating whether a particular address type is valid for a particular address
            isAddressTypeValid: function (addressType, address) {
                var person = JsonApiDataStore.store.find('person', address.person_id);

                // The address type is invalid if another address already has the address type
                var isInvalid = person.addresses.some(function (existingAddress) {
                    return existingAddress.id !== address.id && existingAddress.address_type === addressType;
                });

                // Calculate invalidity and negate because the logic is more intuitive than directly calcualating
                // validity
                return !isInvalid;
            },

            // Determine whether an address has valid field values
            isAddressValid: function (address) {
                return Boolean(address.address_type);
            },

            // Return an address for the specific with default field values
            getAddressTemplate: function (person) {
                // Find the first unused address type
                var addressType = _.chain(editAddressService.getAddressTypes())
                    .difference(_.map(person.addresses, 'address_type'))
                    .first()
                    .defaultTo(null)
                    .value();

                return {
                    _type: 'address',
                    person_id: person.id,
                    address_type: addressType
                };
            },

            // Return an array that resolves to the list of country options
            getCountryOptions: function () {
                return geoDataService.getCountries().then(function (countries) {
                    // Remove the priority countries and then add them back to the front of the list
                    var priorityCountryCodes = ['US', 'CA'];
                    var priorityCountries = priorityCountryCodes.map(function (countryCode) {
                        return _.find(countries, { shortCode: countryCode });
                    });
                    return priorityCountries.concat(_.difference(countries, priorityCountries));
                });
            },

            // Return an array that resolves to the list of region options for a given country
            getRegionOptions: function (countryCode) {
                return geoDataService.getCountries().then(function (countries) {
                    var country = _.find(countries, { shortCode: countryCode });
                    return country ? country.regions : [];
                });
            }
        };

        return editAddressService;
    }
})();
