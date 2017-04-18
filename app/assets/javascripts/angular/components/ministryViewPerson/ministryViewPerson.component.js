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

    function ministryViewPersonController ($scope, RequestDeduper, assignedSelectService, personService,
                                           personProfileService, _) {
        var vm = this;

        vm.assignmentSearch = '';
        vm.assignmentsVisible = false;
        vm.assignmentOptions = [];
        vm.loadingAssignmentOptions = false;
        vm.addAssignment = addAssignment;
        vm.removeAssignment = removeAssignment;
        vm.saveAttribute = saveAttribute;
        vm.toggleAssignmentVisibility = toggleAssignmentVisibility;
        vm.onSearchKeydown = onSearchKeydown;
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

            var requestDeduper = new RequestDeduper();

            // Refresh the person list whenever the search term changes
            $scope.$watch('$ctrl.assignmentSearch', function (search) {
                if (search === '') {
                    // Ignore empty searches
                    vm.assignmentOptions = [];
                    return;
                }

                vm.loadingAssignmentOptions = true;
                assignedSelectService.searchPeople(search, vm.organizationId, requestDeduper)
                    .then(function (people) {
                        // Filter out people that the person is already assigned to
                        vm.assignmentOptions = _.differenceBy(people, vm.assignedTo, 'id');
                    })
                    .finally(function () {
                        vm.loadingAssignmentOptions = false;
                    });
            });
        }

        function addAssignment (person) {
            personProfileService.addAssignments(vm.person, vm.organizationId, [person]).then(function () {
                // Remove the person from the options list
                _.pull(vm.assignmentOptions, person);
            });
        }

        function removeAssignment (person) {
            personProfileService.removeAssignments(vm.person, [person]);
        }

        function saveAttribute (model, attribute) {
            personProfileService.saveAttribute(vm.person.id, model, attribute);
        }

        function toggleAssignmentVisibility () {
            vm.assignmentsVisible = !vm.assignmentsVisible;
        }

        function onSearchKeydown (event) {
            if (event.keyCode === 13) {
                // Enter key was pressed, to add the assignment option if it is the only one
                if (vm.assignmentOptions.length === 1) {
                    vm.addAssignment(vm.assignmentOptions[0]);
                }
            } else if (event.keyCode === 27) {
                // Escape key was pressed, so hide the assignments selector
                vm.assignmentsVisible = false;
            }
        }
    }
})();
