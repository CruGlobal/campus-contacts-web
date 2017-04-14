(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('ministryViewPerson', {
            controller: ministryViewPersonController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('ministryViewPerson');
            },
            bindings: {
                person: '<',
                organizationId: '<',
                selected: '='
            }
        });

    function ministryViewPersonController ($scope, personService, personProfileService) {
        var vm = this;

        vm.saveAttribute = saveAttribute;
        vm.followupStatusOptions = personService.getFollowupStatusOptions();

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

        function saveAttribute (model, attribute) {
            personProfileService.saveAttribute(vm.person.id, model, attribute);
        }
    }
})();
