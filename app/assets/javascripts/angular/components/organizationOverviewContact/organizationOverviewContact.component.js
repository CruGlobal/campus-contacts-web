(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewContact', {
            controller: organizationOverviewContactController,
            templateUrl: '/assets/angular/components/organizationOverviewContact/organizationOverviewContact.html',
            bindings: {
                contact: '<',
                organizationId: '<'
            }
        });

    function organizationOverviewContactController ($scope, personService, contactTabs, _) {
        var vm = this;
        vm.orgPermission = personService.getOrgPermission(vm.contact, vm.organizationId);
        vm.assignedTo = personService.getAssignedTo(vm.contact, vm.organizationId);
        $scope.$watchCollection('$ctrl.contact.email_addresses', function () {
            vm.primaryEmail = _.find(vm.contact.email_addresses, { primary: true });
        });
        $scope.$watchCollection('$ctrl.contact.phone_numbers', function () {
            vm.primaryPhone = _.find(vm.contact.phone_numbers, { primary: true });
        });
        vm.contactTabs = contactTabs;
    }
})();
