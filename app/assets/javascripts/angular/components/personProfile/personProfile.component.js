(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('personProfile', {
            controller: personProfileController,
            require: {
                personTab: '^personPage'
            },
            templateUrl: '/assets/angular/components/personProfile/personProfile.html'
        });

    function personProfileController ($scope, $filter, $uibModal, JsonApiDataStore, jQuery,
                                       personProfileService, loggedInPerson, _, confirmModalService) {
        var vm = this;

        vm.pendingEmailAddress = null;
        vm.pendingPhoneNumber = null;

        vm.saveAttribute = saveAttribute;
        vm.emailAddressesWithPending = emailAddressesWithPending;
        vm.phoneNumbersWithPending = phoneNumbersWithPending;
        vm.addEmailAddress = addEmailAddress;
        vm.addPhoneNumber = addPhoneNumber;
        vm.deleteEmailAddress = deleteEmailAddress;
        vm.deletePhoneNumber = deletePhoneNumber;
        vm.permissionChange = permissionChange;
        vm.editTags = editTags;
        vm.editGroups = editGroups;

        vm.$onInit = activate;
        vm.$onDestroy = onDestroy;

        // Each of these arrays contains all possible values for a partiuclar person attribute
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
            var organization = JsonApiDataStore.store.find('organization', vm.personTab.organizationId);
            if (loggedInPerson.person === vm.personTab.person) {
                vm.permissionChangeDisabled = true;
            } else if (!loggedInPerson.isAdminAt(organization)) {
                if (vm.personTab.orgPermission.permission_id === 1) {
                    vm.permissionChangeDisabled = true;
                } else {
                    vm.permissionOptions.shift();
                }
            }

            // Save the changes on the server whenever the primary email or primary phone changes
            $scope.$watch('$ctrl.personTab.primaryEmail', updatePrimary);
            $scope.$watch('$ctrl.personTab.primaryPhone', updatePrimary);

            $scope.$watchCollection('$ctrl.personTab.assignedTo', function (newAssignedTo, oldAssignedTo) {
                var addedPeople = _.difference(newAssignedTo, oldAssignedTo);
                personProfileService.addAssignments(vm.personTab.person, vm.personTab.organizationId, addedPeople);

                var removedPeople = _.difference(oldAssignedTo, newAssignedTo);
                personProfileService.removeAssignments(vm.personTab.person, removedPeople);
            });

            $scope.$watchCollection('$ctrl.personTab.person.gender', function (newGender, oldGender) {
                if (newGender !== oldGender) {
                    saveAttribute(vm.personTab.person, 'gender');
                }
            });
        }

        function onDestroy () {
            vm.modalInstance.close();
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
            personProfileService.saveAttribute(vm.personTab.person.id, model, attribute).then(function () {
                if (model === vm.pendingEmailAddress) {
                    vm.pendingEmailAddress = null;
                } else if (model === vm.pendingPhoneNumber) {
                    vm.pendingPhoneNumber = null;
                }
            });
        }

        function emailAddressesWithPending () {
            var emailAddresses = vm.personTab.person.email_addresses;
            if (!vm.pendingEmailAddress) {
                addEmailAddress();
            }
            return emailAddresses.concat(vm.pendingEmailAddress);
        }

        function phoneNumbersWithPending () {
            var phoneNumbers = vm.personTab.person.phone_numbers;
            if (!vm.pendingPhoneNumber) {
                addPhoneNumber();
            }
            return phoneNumbers.concat(vm.pendingPhoneNumber);
        }

        // Add a new email address to the person
        // The email address is not actually saved to the server until the call to saveAttribute
        function addEmailAddress () {
            vm.pendingEmailAddress = {
                _type: 'email_address',
                person_id: vm.personTab.person.id
            };
        }

        // Add a new phone number to the person
        // The phone number is not actually saved to the server until the call to saveAttribute
        function addPhoneNumber () {
            vm.pendingPhoneNumber = {
                _type: 'phone_number',
                person_id: vm.personTab.person.id
            };
        }

        function deleteEmailAddress (emailAddress) {
            var message = $filter('t')('people.edit.delete_email_confirm');
            var confirmModal = confirmModalService.create(message);

            confirmModal.then(function () {
                return personProfileService.deleteModel(emailAddress).then(function () {
                    // Remove the deleted email address
                    _.pull(vm.personTab.person.email_addresses, emailAddress);
                });
            });
        }

        function deletePhoneNumber (phoneNumber) {
            var message = $filter('t')('people.edit.delete_phone_confirm');
            var confirmModal = confirmModalService.create(message);

            confirmModal.then(function () {
                return personProfileService.deleteModel(phoneNumber).then(function () {
                    // Remove the deleted phone number
                    _.pull(vm.personTab.person.phone_numbers, phoneNumber);
                });
            });
        }

        /*
        This is used on the profile component with a tricky interpolation that results in it
        returning the old value. It looks like this:
        ng-change="$ctrl.permissionChange({{$ctrl.personTab.orgPermission.permission_id}})"
        Reference: http://stackoverflow.com/a/28047112/879524
         */
        function permissionChange (oldValue) {
            var hasEmailAddress = vm.personTab.person.email_addresses.length > 0;
            if (hasEmailAddress) {
                vm.saveAttribute(vm.personTab.orgPermission, 'permission_id');
            } else {
                vm.personTab.orgPermission.permission_id = oldValue;
                jQuery.a($filter('t')('people.index.for_this_permission_email_is_required_no_name'));
            }
        }

        function editTags () {
            editLabelsOrGroups('organizational_labels', vm.personTab.updateLabels);
        }

        function editGroups () {
            editLabelsOrGroups('group_memberships', vm.personTab.updateGroupMemberships);
        }

        function editLabelsOrGroups (relationship, updateFunction) {
            vm.modalInstance = $uibModal.open({
                animation: true,
                component: 'editGroupOrLabelAssignments',
                resolve: {
                    organizationId: function () {
                        return vm.personTab.organizationId;
                    },
                    person: function () {
                        return vm.personTab.person;
                    },
                    relationship: function () {
                        return relationship;
                    }
                },
                windowClass: 'pivot_theme',
                size: 'sm'
            });

            vm.modalInstance.result.then(function () {
                updateFunction();
            });
        }
    }
})();
