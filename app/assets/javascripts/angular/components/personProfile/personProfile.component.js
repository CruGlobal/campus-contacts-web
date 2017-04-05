(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('personProfile', {
            controller: personProfileController,
            require: {
                personTab: '^personPage'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('personProfile');
            }
        });

    function personProfileController ($scope, $filter, $uibModal, JsonApiDataStore, jQuery, geoDataService,
                                      personService, personProfileService, loggedInPerson, _, confirmModalService) {
        var vm = this;

        vm.pendingEmailAddress = null;
        vm.pendingPhoneNumber = null;
        vm.modalInstance = null;

        vm.saveAttribute = saveAttribute;
        vm.saveRelationship = saveRelationship;
        vm.emailAddressesWithPending = emailAddressesWithPending;
        vm.phoneNumbersWithPending = phoneNumbersWithPending;
        vm.isPendingEmailAddress = isPendingEmailAddress;
        vm.isPendingPhoneNumber = isPendingPhoneNumber;
        vm.addEmailAddress = addEmailAddress;
        vm.addPhoneNumber = addPhoneNumber;
        vm.deleteEmailAddress = deleteEmailAddress;
        vm.deletePhoneNumber = deletePhoneNumber;
        vm.deleteAddress = deleteAddress;
        vm.permissionChange = permissionChange;
        vm.editTags = editTags;
        vm.editGroups = editGroups;
        vm.editAddress = editAddress;
        vm.formatAddress = personProfileService.formatAddress;

        vm.$onInit = activate;
        vm.$onDestroy = onDestroy;

        vm.followupStatusOptions = personService.getFollowupStatusOptions();
        vm.cruStatusOptions = personService.getCruStatusOptions();
        vm.permissionOptions = personService.getPermissionOptions();
        vm.enrollmentOptions = personService.getEnrollmentOptions();

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
                if (newAssignedTo === oldAssignedTo) {
                    return;
                }

                $scope.$emit('personModified');

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
            if (vm.modalInstance) {
                vm.modalInstance.close();
            }
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
            $scope.$emit('personModified');

            personProfileService.saveAttribute(vm.personTab.person.id, model, attribute);
        }

        function saveRelationship (relationship, attribute, relationshipName) {
            $scope.$emit('personModified');

            var savePromise = personProfileService.saveRelationship(vm.personTab.person, relationship,
                                                                    relationshipName, attribute);
            savePromise.then(function () {
                if (relationship === vm.pendingEmailAddress) {
                    vm.pendingEmailAddress = null;
                } else if (relationship === vm.pendingPhoneNumber) {
                    vm.pendingPhoneNumber = null;
                }
            });
        }

        function deleteRelationship (relationship, relationshipName) {
            $scope.$emit('personModified');

            personProfileService.deleteRelationship(vm.personTab.person, relationship, relationshipName);
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

        function isPendingEmailAddress (emailAddress) {
            return emailAddress === vm.pendingEmailAddress;
        }

        function isPendingPhoneNumber (phoneNumber) {
            return phoneNumber === vm.pendingPhoneNumber;
        }

        // Add a new email address to the person
        // The email address is not actually saved to the server until the call to saveAttribute
        function addEmailAddress () {
            vm.pendingEmailAddress = new JsonApiDataStore.Model('email_address');
            vm.pendingEmailAddress.setAttribute('person_id', vm.personTab.person.id);
            vm.pendingEmailAddress.setAttribute('email', '');
            vm.pendingEmailAddress.setAttribute('primary', false);
        }

        // Add a new phone number to the person
        // The phone number is not actually saved to the server until the call to saveAttribute
        function addPhoneNumber () {
            vm.pendingPhoneNumber = new JsonApiDataStore.Model('phone_number');
            vm.pendingPhoneNumber.setAttribute('person_id', vm.personTab.person.id);
            vm.pendingPhoneNumber.setAttribute('number', '');
            vm.pendingPhoneNumber.setAttribute('primary', false);
        }

        function deleteEmailAddress (emailAddress) {
            var message = $filter('t')('people.edit.delete_email_confirm');
            var confirmModal = confirmModalService.create(message);

            confirmModal.then(function () {
                deleteRelationship(emailAddress, 'email_addresses');
            });
        }

        function deletePhoneNumber (phoneNumber) {
            var message = $filter('t')('people.edit.delete_phone_confirm');
            var confirmModal = confirmModalService.create(message);

            confirmModal.then(function () {
                deleteRelationship(phoneNumber, 'phone_numbers');
            });
        }

        function deleteAddress (address) {
            var message = $filter('t')('people.edit.delete_address_confirm');
            var confirmModal = confirmModalService.create(message);

            confirmModal.then(function () {
                deleteRelationship(address, 'addresses');
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
                jQuery.a($filter('t')('contacts.index.for_this_permission_email_is_required_no_name'));
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
                $scope.$emit('personModified');

                updateFunction();
            }).finally(function () {
                vm.modalInstance = null;
            });
        }

        // Open an address for editing in a modal dialog
        function editAddress (address) {
            var addressModal = $uibModal.open({
                animation: true,
                component: 'editAddress',
                resolve: {
                    organizationId: function () {
                        return vm.personTab.organizationId;
                    },

                    person: function () {
                        return vm.personTab.person;
                    },

                    address: function () {
                        return address;
                    }
                },
                windowClass: 'pivot_theme',
                size: 'sm'
            });

            addressModal.result.then(function () {
                $scope.$emit('personModified');
            });
        }
    }
})();
