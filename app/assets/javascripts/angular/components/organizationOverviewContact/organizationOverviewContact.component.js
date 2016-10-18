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

    function organizationOverviewContactController (personService, contactTabs, _) {
        var vm = this;
        vm.orgPermission = personService.getOrgPermission(vm.contact, vm.organizationId);
        vm.assignedTo = personService.getAssignedTo(vm.contact, vm.organizationId);
        vm.primaryEmail = _.find(vm.contact.email_addresses, { primary: true });
        vm.primaryPhone = _.find(vm.contact.phone_numbers, { primary: true });
        vm.contactTabs = contactTabs;
    }
})();
