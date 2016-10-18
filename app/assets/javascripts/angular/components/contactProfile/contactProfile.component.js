(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('contactProfile', {
            controller: contactProfileController,
            require: {
                contactTab: '^organizationOverviewContact'
            },
            templateUrl: '/assets/angular/components/contactProfile/contactProfile.html'
        });

    function contactProfileController ($scope, contactProfileService) {
        var vm = this;
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
            vm.emailAddresses = vm.contactTab.contact.email_addresses;
            vm.phoneNumbers = vm.contactTab.contact.phone_numbers;

            // Save the changes on the server whenever the primary email or primary phone changes
            $scope.$watch('$ctrl.contactTab.primaryEmail', updatePrimary);
            $scope.$watch('$ctrl.contactTab.primaryPhone', updatePrimary);
        }

        function updatePrimary (newPrimary, oldPrimary) {
            if (newPrimary === oldPrimary) {
                // Do nothing if the primary item is not changing
                return;
            }

            newPrimary.primary = true;
            saveAttribute(newPrimary, 'primary');

            oldPrimary.primary = false;
        }

        function saveAttribute (model, attribute) {
            contactProfileService.saveAttribute(vm.contactTab.contact.id, model, attribute);
        }
    }
})();
