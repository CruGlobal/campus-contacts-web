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

        vm.loadingAssignmentOptions = false;
        vm.addAssignment = addAssignment;
        vm.removeAssignment = removeAssignment;
        vm.saveAttribute = saveAttribute;
        vm.toggleAssignmentVisibility = toggleAssignmentVisibility;
        vm.onAssignmentsKeydown = onAssignmentsKeydown;
        vm.isContact = isContact;
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

        function addAssignment (person) {
            return personProfileService.addAssignments(vm.person, vm.organizationId, [person]);
        }

        function removeAssignment (person) {
            return personProfileService.removeAssignments(vm.person, [person]);
        }

        function saveAttribute (model, attribute) {
            personProfileService.saveAttribute(vm.person.id, model, attribute);
        }

        function toggleAssignmentVisibility () {
            vm.assignmentsVisible = !vm.assignmentsVisible;
        }

        function onAssignmentsKeydown (event) {
            if (event.keyCode === 27) {
                // Escape key was pressed, so hide the assignments selector
                vm.assignmentsVisible = false;
            }
        }

        function isContact () {
            return personService.isContact(vm.person, vm.organizationId);
        }
    }
})();
