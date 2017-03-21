(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('ministryViewPerson', {
            controller: ministryViewPersonController,
            templateUrl: '/assets/angular/components/ministryViewPerson/ministryViewPerson.html',
            bindings: {
                person: '<',
                organizationId: '<',
                selected: '='
            }
        });

    function ministryViewPersonController ($scope, personService) {
        var vm = this;

        vm.$onInit = activate;

        function activate () {
            $scope.$watchCollection('$ctrl.person.organizational_permissions', function () {
                vm.orgPermission = personService.getOrgPermission(vm.person, vm.organizationId);
            });

            $scope.$watchCollection('$ctrl.person.reverse_contact_assignments', function () {
                vm.assignedTo = personService.getAssignedTo(vm.person, vm.organizationId);
            });

            $scope.$watchCollection('$ctrl.person.phone_numbers', function () {
                vm.phoneNumber = personService.getPhoneNumber(vm.person);
            });

            $scope.$watchCollection('$ctrl.person.email_addresses', function () {
                vm.emailAddress = personService.getEmailAddress(vm.person);
            });
        }
    }
})();
