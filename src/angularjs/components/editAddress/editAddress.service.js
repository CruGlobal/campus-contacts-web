angular
  .module('missionhubApp')
  .factory('editAddressService', editAddressService);

editAddressService.$inject = ['geoDataService', 'JsonApiDataStore', '_'];
function editAddressService(geoDataService, JsonApiDataStore, _) {
  var editAddressService = {
    // Return an array of valid address types
    getAddressTypes: function() {
      return ['current', 'permanent', 'emergency1', 'emergency2'];
    },

    // Return a boolean indicating whether a particular address type is valid for a particular person's address
    isAddressTypeValid: function(addressType, otherAddresses) {
      // The address type is valid if no other addresses already have the address type
      return !_.find(otherAddresses, { address_type: addressType });
    },

    // Determine whether an address has valid field values
    isAddressValid: function(address) {
      return Boolean(address.address_type);
    },

    // Return an address for the specific with default field values
    getAddressTemplate: function(person) {
      // Find the first unused address type
      var addressType = _
        .chain(editAddressService.getAddressTypes())
        .difference(_.map(person.addresses, 'address_type'))
        .first()
        .defaultTo(null)
        .value();

      var address = new JsonApiDataStore.Model('address');
      address.setAttribute('person_id', person.id);
      address.setAttribute('address_type', addressType);
      [
        'address1',
        'address2',
        'address3',
        'address4',
        'city',
        'state',
        'zip',
        'country',
      ].forEach(function(attribute) {
        address.setAttribute(attribute, '');
      });
      return address;
    },

    // Return an array that resolves to the list of country options
    getCountryOptions: function() {
      return geoDataService.getCountries().then(function(countries) {
        // Remove the priority countries and then add them back to the front of the list
        var priorityCountryCodes = ['US', 'CA'];
        var priorityCountries = priorityCountryCodes.map(function(countryCode) {
          return _.find(countries, { shortCode: countryCode });
        });
        return priorityCountries.concat(
          _.difference(countries, priorityCountries),
        );
      });
    },

    // Return an array that resolves to the list of region options for a given country
    getRegionOptions: function(countryCode) {
      return geoDataService.getCountries().then(function(countries) {
        var country = _.find(countries, { shortCode: countryCode });
        return country ? country.regions : [];
      });
    },
  };

  return editAddressService;
}
