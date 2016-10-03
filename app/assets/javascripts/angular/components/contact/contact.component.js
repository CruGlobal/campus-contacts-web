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

    function contactController (personService, _) {
        var vm = this;
        vm.uncontacted = personService.getFollowupStatus(vm.contact, vm.organizationId) === 'uncontacted';
        vm.assignedTo = personService.getAssignedTo(vm.contact, vm.organizationId);
        vm.phoneNumber = _.chain(vm.contact.phone_numbers).map('number').first().defaultTo(null).value();
        vm.emailAddress = _.chain(vm.contact.email_addresses).map('email').first().defaultTo(null).value();
    }
})();
