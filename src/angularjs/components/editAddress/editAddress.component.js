editAddressController.$inject = [
  'editAddressService',
  'personProfileService',
  '_',
];
import template from './editAddress.html';
import './editAddress.scss';

angular.module('missionhubApp').component('editAddress', {
  controller: editAddressController,
  bindings: {
    resolve: '<',
    close: '&',
    dismiss: '&',
  },
  template: template,
});

function editAddressController(editAddressService, personProfileService, _) {
  var vm = this;

  vm.saving = false;
  vm.addressTypes = editAddressService.getAddressTypes();

  vm.valid = valid;
  vm.loadRegions = loadRegions;
  vm.isAddressTypeValid = isAddressTypeValid;
  vm.save = save;
  vm.cancel = cancel;

  vm.$onInit = activate;

  function activate() {
    vm.person = vm.resolve.person;

    // This will be true if we are creating a new contact and false if we are editing an existing contact
    vm.isNewAddress = vm.resolve.address === null;

    // Copy the address so that the changes can be discard if the user does not save
    var address = vm.resolve.address;
    vm.address = address
      ? _.clone(address)
      : editAddressService.getAddressTemplate(vm.person);

    // Get the list of the user's other addresses
    vm.otherAddresses = _.without(vm.person.addresses, address);

    loadCountries().then(function() {
      // For now, US regions are the only valid region choices
      loadRegions('US');
    });
  }

  function valid() {
    return editAddressService.isAddressValid(vm.address);
  }

  // Populate vm.countries with the valid country choices
  function loadCountries() {
    return editAddressService.getCountryOptions().then(function(countries) {
      vm.countries = countries;
    });
  }

  // Populate vm.countries with the valid region choices
  function loadRegions(countryCode) {
    return editAddressService
      .getRegionOptions(countryCode)
      .then(function(regions) {
        vm.regions = regions;
      });
  }

  function isAddressTypeValid(addressType) {
    return editAddressService.isAddressTypeValid(
      addressType,
      vm.otherAddresses,
    );
  }

  // Persist the changes to the address to the server
  function save() {
    vm.saving = true;
    personProfileService
      .saveAttribute(vm.person.id, vm.address, _.keys(vm.address))
      .then(function() {
        if (vm.person.id === null && vm.isNewAddress) {
          // The person is not saved on the server, so manually add the new address to the person
          vm.person.addresses.push(vm.address);
        }

        if (!vm.isNewAddress) {
          // Apply the changes to the original address
          _.extend(vm.resolve.address, vm.address);
        }

        vm.close({ $value: vm.address });
      })
      .catch(function() {
        vm.saving = false;
      });
  }

  function cancel() {
    vm.dismiss();
  }
}
