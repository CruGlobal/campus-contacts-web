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

    function organizationOverviewContactController ($scope, personService, organizationOverviewContactService, _) {
        var vm = this;
        vm.orgPermission = personService.getOrgPermission(vm.contact, vm.organizationId);
        vm.assignedTo = personService.getAssignedTo(vm.contact, vm.organizationId);
        vm.emailAddresses = vm.contact.email_addresses;
        vm.primaryEmail = _.find(vm.emailAddresses, { primary: true });
        vm.phoneNumbers = vm.contact.phone_numbers;
        vm.primaryPhone = _.find(vm.phoneNumbers, { primary: true });

        vm.saveAttribute = saveAttribute;
        vm.$onInit = activate;

        // Each of these arrays contains all possible values for a partiuclar contact attribute
        // The ids also match the last part of the i18n label path (i.e., 'cru_status.{none,volunteer,affiliate,...}')
        vm.followupStatusIds = [
            'attempted_contact',
            'completed',
            'contacted',
            'do_not_contact',
            'uncontacted'
        ];
        vm.cruStatusIds = [
            'none',
            'volunteer',
            'affiliate',
            'intern',
            'part_time_staff',
            'full_time_staff'
        ];
        vm.enrollmentIds = [
            'not_student',
            'middle_school',
            'high_school',
            'collegiate',
            'masters_or_doctorate'
        ];

        function activate () {
            // Save the changes on the server whenever the primary email or primary phone changes
            $scope.$watch('$ctrl.primaryEmail', updatePrimary);
            $scope.$watch('$ctrl.primaryPhone', updatePrimary);
        }

        function updatePrimary (newPrimary, oldPrimary) {
            if (newPrimary === oldPrimary) {
                // Do nothing if the primary item is not changing
                return;
            }

            newPrimary.primary = true;
            vm.saveAttribute(newPrimary, 'primary');

            oldPrimary.primary = false;
        }

        function saveAttribute (model, attribute) {
            organizationOverviewContactService.saveAttribute(vm.contact.id, model, attribute);
        }
    }
})();
