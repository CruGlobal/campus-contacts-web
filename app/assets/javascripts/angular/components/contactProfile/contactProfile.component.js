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

    function contactProfileController ($scope, $filter, JsonApiDataStore, jQuery,
                                       contactProfileService, loggedInPerson, _) {
        var vm = this;

        vm.pendingEmailAddress = null;
        vm.pendingPhoneNumber = null;

        vm.saveAttribute = saveAttribute;
        vm.getEmailAddresses = getEmailAddresses;
        vm.getPhoneNumbers = getPhoneNumbers;
        vm.addEmailAddress = addEmailAddress;
        vm.addPhoneNumber = addPhoneNumber;
        vm.deleteEmailAddress = deleteEmailAddress;
        vm.deletePhoneNumber = deletePhoneNumber;
        vm.permissionChange = permissionChange;

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
        vm.permissionOptions = [
            { id: 1, i18n: 'admin' },
            { id: 4, i18n: 'user' },
            { id: 2, i18n: 'no_permissions' }
        ];
        vm.enrollmentIds = [
            'not_student',
            'middle_school',
            'high_school',
            'collegiate',
            'masters_or_doctorate'
        ];

        function activate () {
            var organization = JsonApiDataStore.store.find('organization', vm.contactTab.organizationId);
            if (loggedInPerson.person === vm.contactTab.contact) {
                vm.permissionChangeDisabled = true;
            } else if (!loggedInPerson.isAdminAt(organization)) {
                if (vm.contactTab.orgPermission.permission_id === 1) {
                    vm.permissionChangeDisabled = true;
                } else {
                    vm.permissionOptions.shift();
                }
            }

            // Save the changes on the server whenever the primary email or primary phone changes
            $scope.$watch('$ctrl.contactTab.primaryEmail', updatePrimary);
            $scope.$watch('$ctrl.contactTab.primaryPhone', updatePrimary);

            // Whenever the contact has no email addresses or phone numbers, show the add email address or add phone
            // number form
            $scope.$watch('$ctrl.contactTab.contact.email_addresses.length', function (newLength) {
                if (newLength === 0) {
                    vm.addEmailAddress();
                }
            });
            $scope.$watch('$ctrl.contactTab.contact.phone_numbers.length', function (newLength) {
                if (newLength === 0) {
                    vm.addPhoneNumber();
                }
            });

            $scope.$watchCollection('$ctrl.contactTab.assignedTo', function (newAssignedTo, oldAssignedTo) {
                var addedPeople = _.difference(newAssignedTo, oldAssignedTo);
                contactProfileService.addAssignments(vm.contactTab.contact, vm.contactTab.organizationId, addedPeople);

                var removedPeople = _.difference(oldAssignedTo, newAssignedTo);
                contactProfileService.removeAssignments(vm.contactTab.contact, removedPeople);
            });

            $scope.$watchCollection('$ctrl.contactTab.contact.gender', function (newGender, oldGender) {
                if (newGender !== oldGender) {
                    saveAttribute(vm.contactTab.contact, 'gender');
                }
            });
        }

        function updatePrimary (newPrimary, oldPrimary) {
            if (newPrimary === oldPrimary) {
                // Do nothing if the primary item is not changing
                return;
            }

            if (newPrimary && !newPrimary.primary) {
                newPrimary.primary = true;
                saveAttribute(newPrimary, 'primary');
            }

            if (oldPrimary) {
                oldPrimary.primary = false;
            }
        }

        function saveAttribute (model, attribute) {
            contactProfileService.saveAttribute(vm.contactTab.contact.id, model, attribute).then(function () {
                if (model === vm.pendingEmailAddress) {
                    vm.pendingEmailAddress = null;
                } else if (model === vm.pendingPhoneNumber) {
                    vm.pendingPhoneNumber = null;
                }
            });
        }

        function getEmailAddresses () {
            var emailAddresses = vm.contactTab.contact.email_addresses;
            return vm.pendingEmailAddress ? emailAddresses.concat(vm.pendingEmailAddress) : emailAddresses;
        }

        function getPhoneNumbers () {
            var phoneNumbers = vm.contactTab.contact.phone_numbers;
            return vm.pendingPhoneNumber ? phoneNumbers.concat(vm.pendingPhoneNumber) : phoneNumbers;
        }

        // Add a new email address to the contact
        // The email address is not actually saved to the server until the call to saveAttribute
        function addEmailAddress () {
            vm.pendingEmailAddress = {
                _type: 'email_address',
                person_id: vm.contactTab.contact.id
            };
        }

        // Add a new phone number to the contact
        // The phone number is not actually saved to the server until the call to saveAttribute
        function addPhoneNumber () {
            vm.pendingPhoneNumber = {
                _type: 'phone_number',
                person_id: vm.contactTab.contact.id
            };
        }

        function deleteEmailAddress (emailAddress) {
            return contactProfileService.deleteModel(emailAddress).then(function () {
                // Remove the deleted email address
                _.pull(vm.contactTab.contact.email_addresses, emailAddress);
            });
        }

        function deletePhoneNumber (phoneNumber) {
            return contactProfileService.deleteModel(phoneNumber).then(function () {
                // Remove the deleted phone number
                _.pull(vm.contactTab.contact.phone_numbers, phoneNumber);
            });
        }

        /*
        This is used on the profile component with a tricky interpolation that results in it
        returning the old value. It looks like this:
        ng-change="$ctrl.permissionChange({{$ctrl.contactTab.orgPermission.permission_id}})"
        Reference: http://stackoverflow.com/a/28047112/879524
         */
        function permissionChange (oldValue) {
            var hasEmailAddress = vm.contactTab.contact.email_addresses.length > 0;
            if (hasEmailAddress) {
                vm.saveAttribute(vm.contactTab.orgPermission, 'permission_id');
            } else {
                vm.contactTab.orgPermission.permission_id = oldValue;
                jQuery.a($filter('t')('contacts.index.for_this_permission_email_is_required_no_name'));
            }
        }
    }
})();
