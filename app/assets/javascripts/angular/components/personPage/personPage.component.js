(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('personPage', {
            controller: personPageController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('personPage');
            },
            bindings: {
                stateName: '<',
                person: '<',
                organizationId: '<',
                options: '='
            }
        });

    function personPageController ($scope, $state, $filter, $q, $transitions, asyncBindingsService, personService,
                                   personTabs, confirmModalService, personPageService, _) {
        var vm = this;
        vm.personTabs = personTabs;
        vm.orgLabels = [];
        vm.dirty = false;

        vm.uploadAvatar = uploadAvatar;
        vm.deleteAvatar = deleteAvatar;
        vm.updateLabels = updateLabels;
        vm.dismiss = dismiss;
        vm.save = save;
        vm.updateGroupMemberships = updateGroupMemberships;
        vm.$onInit = asyncBindingsService.lazyLoadedActivate(activate, ['person', 'organizationId']);

        function activate () {
            $scope.$on('personModified', function () {
                vm.dirty = true;
            });

            vm.orgPermission = personService.getOrgPermission(vm.person, vm.organizationId);
            vm.assignedTo = personService.getAssignedTo(vm.person, vm.organizationId);
            $scope.$watch('$ctrl.person.picture', function (pictureUrl) {
                vm.avatarUrl = pictureUrl || $filter('assetPath')('no_image.png');
                vm.isFacebookAvatar = personPageService.isFacebookAvatar(vm.avatarUrl);
                if (vm.isFacebookAvatar) {
                    vm.avatarUrl += '?width=120&height=120';
                }
            });

            $scope.$watchCollection('$ctrl.person.email_addresses', function (relationships) {
                vm.primaryEmail = _.find(relationships, { primary: true });
                if (!vm.primaryEmail && relationships.length > 0) {
                    // The primary email address defaults to the first one
                    vm.primaryEmail = _.first(relationships);
                    vm.primaryEmail.primary = true;
                }
            });
            $scope.$watchCollection('$ctrl.person.phone_numbers', function (relationships) {
                vm.primaryPhone = _.find(relationships, { primary: true });
                if (!vm.primaryPhone && relationships.length > 0) {
                    // The primary phone number defaults to the first one
                    vm.primaryPhone = _.first(relationships);
                    vm.primaryPhone.primary = true;
                }
            });

            updateLabels();
            updateGroupMemberships();

            beginDismissLock();
        }

        var unsubscribeTransition, unsubscribeClose;

        // Prevent the modal from being closed without a confirmation dialog
        function beginDismissLock () {
            // Intercept transitions away from this component
            unsubscribeTransition = $transitions.onBefore({ exiting: vm.stateName }, function () {
                return confirmCancel()
                    .then(function () {
                        // Allow the transition to proceede
                        endDismissLock();
                    })
                    .catch(function () {
                        // Cancel the transition
                        return false;
                    });
            });

            // Intercept close events, prevent the modal from closing, and display the dismissal confirmation
            unsubscribeClose = $scope.$on('modal.closing', function (event) {
                event.preventDefault();
                vm.dismiss();
            });
        }

        // Allow the modal to be closed without a confirmation dialog
        function endDismissLock () {
            unsubscribeTransition();
            unsubscribeClose();
        }

        function uploadAvatar (file) {
            if (file) {
                personPageService.uploadAvatar(vm.person, file);
            }
        }

        function deleteAvatar () {
            personPageService.deleteAvatar(vm.person);
        }

        function updateLabels () {
            vm.orgLabels = personService.getOrgLabels(vm.person, vm.organizationId);
        }

        // If necessary, display a confirmation dialog asking whether the user wants to cancel their changes to the
        // current contact
        function confirmCancel () {
            return $q.resolve().then(function () {
                if (vm.person.id === null && vm.dirty) {
                    // Receive confirmation before canceling the creation of a new contact
                    return confirmModalService.create($filter('t')('people.edit.cancel_create_confirm'));
                }
            });
        }

        // Dismiss this page
        function dismiss () {
            return confirmCancel().then(function () {
                endDismissLock();
                $state.go('^.^');
            });
        }

        // Save the pending changes and dismiss
        function save () {
            vm.saving = true;
            personPageService.savePerson(vm.person)
                .then(function (person) {
                    // Update our person model with the newly-saved one. If it is a newly-created person, it will have
                    // an id now, and the dismiss call will not ask for a confirmation before navigating away.
                    vm.person = person;
                    $scope.$emit('personCreated', vm.person);
                    vm.dismiss();
                })
                .catch(function () {
                    vm.saving = false;
                });
        }

        function updateGroupMemberships () {
            vm.groupMemberships = personService.getGroupMemberships(vm.person, vm.organizationId);
        }
    }
})();
