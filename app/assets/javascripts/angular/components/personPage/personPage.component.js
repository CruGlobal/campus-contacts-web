(function () {
    'use strict';

    var bindings = {
        stateName: '<',
        person: '<',
        organizationId: '<'
    };

    angular
        .module('missionhubApp')
        .component('personPage', {
            controller: personPageController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('personPage');
            },
            bindings: bindings
        });

    function personPageController ($scope, $state, $filter, asyncBindingsService, personService, personTabs,
                                   personPageService, _) {
        var vm = this;
        vm.personTabs = personTabs;
        vm.orgLabels = [];

        vm.uploadAvatar = uploadAvatar;
        vm.deleteAvatar = deleteAvatar;
        vm.updateLabels = updateLabels;
        vm.dismiss = dismiss;
        vm.updateGroupMemberships = updateGroupMemberships;
        vm.$onInit = preactivate;

        function preactivate () {
            asyncBindingsService.resolveAsyncBindings(vm, _.keys(bindings)).then(function () {
                vm.ready = true;
                activate();
            });
        }

        function activate () {
            vm.orgPermission = personService.getOrgPermission(vm.person, vm.organizationId);
            vm.assignedTo = personService.getAssignedTo(vm.person, vm.organizationId);
            $scope.$watch('$ctrl.person.picture', function (pictureUrl) {
                vm.avatarUrl = pictureUrl || $filter('assetPath')('no_image.png');
                vm.isFacebookAvatar = personPageService.isFacebookAvatar(vm.avatarUrl);
                if (vm.isFacebookAvatar) {
                    vm.avatarUrl += '?width=120&height=120';
                }
            });

            $scope.$watchCollection('$ctrl.person.email_addresses', function () {
                vm.primaryEmail = _.find(vm.person.email_addresses, { primary: true });
            });
            $scope.$watchCollection('$ctrl.person.phone_numbers', function () {
                vm.primaryPhone = _.find(vm.person.phone_numbers, { primary: true });
            });

            updateLabels();
            updateGroupMemberships();
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

        // Dismiss this page
        function dismiss () {
            $state.go('^.^');
        }

        function updateGroupMemberships () {
            vm.groupMemberships = personService.getGroupMemberships(vm.person, vm.organizationId);
        }
    }
})();
