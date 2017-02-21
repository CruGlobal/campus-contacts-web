(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('editAddress', {
            controller: editAddressController,
            bindings: {
                resolve: '<',
                close: '&',
                dismiss: '&'
            },
            templateUrl: '/assets/angular/components/editAddress/editAddress.html'
        });

    function editAddressController (editAddressService, personProfileService, geoDataService, JsonApiDataStore, _) {
        var vm = this;

        vm.saving = false;
        vm.addressTypes = editAddressService.getAddressTypes();

        vm.valid = valid;
        vm.loadRegions = loadRegions;
        vm.isAddressTypeValid = isAddressTypeValid;
        vm.save = save;
        vm.cancel = cancel;

        vm.$onInit = activate;

        function activate () {
            vm.person = JsonApiDataStore.store.find('person', vm.resolve.personId);

            // Copy the address so that the changes can be discard if the user does not save
            var address = vm.resolve.address;
            vm.address = address ? _.clone(address) : editAddressService.getAddressTemplate(vm.person);

            loadCountries().then(function () {
                // For now, US regions are the only valid region choices
                loadRegions('US');
            });
        }

        function valid () {
            return editAddressService.isAddressValid(vm.address);
        }

        // Populate vm.countries with the valid country choices
        function loadCountries () {
            return editAddressService.getCountryOptions().then(function (countries) {
                vm.countries = countries;
            });
        }

        // Populate vm.countries with the valid region choices
        function loadRegions (countryCode) {
            return editAddressService.getRegionOptions(countryCode).then(function (regions) {
                vm.regions = regions;
            });
        }

        function isAddressTypeValid (addressType, address) {
            return editAddressService.isAddressTypeValid(addressType, address);
        }

        // Persist the changes to the address to the server
        function save () {
            vm.saving = true;
            personProfileService.saveAttribute(vm.person.id, vm.address, _.keys(vm.address))
                .then(function () {
                    // Apply the changes to the original address
                    _.extend(vm.resolve.address, vm.address);
                    vm.close({ $value: vm.address });
                })
                .catch(function () {
                    vm.saving = false;
                });
        }

        function cancel () {
            vm.dismiss();
        }
    }
})();
