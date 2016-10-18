(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('contact', {
            controller: contactController,
            templateUrl: '/assets/angular/components/contact/contact.html',
            bindings: {
                contact: '<',
                organizationId: '<'
            }
        });

    function contactController (personService, contactFirstTab) {
        var vm = this;
        vm.uncontacted = personService.getFollowupStatus(vm.contact, vm.organizationId) === 'uncontacted';
        vm.assignedTo = personService.getAssignedTo(vm.contact, vm.organizationId);
        vm.phoneNumber = personService.getPhoneNumber(vm.contact);
        vm.emailAddress = personService.getEmailAddress(vm.contact);
        vm.contactFirstTab = contactFirstTab;
    }
})();
