(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('ministryViewPerson', {
            controller: ministryViewPersonController,
            templateUrl: '/assets/angular/components/ministryViewPerson/ministryViewPerson.html',
            bindings: {
                person: '<',
                organizationId: '<'
            }
        });

    function ministryViewPersonController ($scope, personService) {
        var vm = this;

        vm.$onInit = activate;

        function activate () {
            vm.uncontacted = personService.getFollowupStatus(vm.person, vm.organizationId) === 'uncontacted';
            vm.assignedTo = personService.getAssignedTo(vm.person, vm.organizationId);
            vm.phoneNumber = personService.getPhoneNumber(vm.person);
            vm.emailAddress = personService.getEmailAddress(vm.person);
        }

        $scope.$watch('$ctrl.person.reverse_contact_assignments', function () {
            vm.assignedTo = personService.getAssignedTo(vm.person, vm.organizationId);
        });
    }
})();
