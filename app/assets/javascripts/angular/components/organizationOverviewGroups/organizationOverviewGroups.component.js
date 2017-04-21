(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewGroups', {
            controller: organizationOverviewGroupsController,
            require: {
                organizationOverview: '^'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('organizationOverviewGroups');
            }
        });

    function organizationOverviewGroupsController ($uibModal, _) {
        var vm = this;
        vm.addGroup = addGroup;
        vm.editGroup = editGroup;

        function addGroup () {
            $uibModal.open({
                component: 'editGroup',
                resolve: {
                    organizationId: _.constant(vm.organizationOverview.org.id)
                },
                windowClass: 'pivot_theme',
                size: 'sm'
            });

            return false;
        }

        function editGroup (group) {
            $uibModal.open({
                component: 'editGroup',
                resolve: {
                    organizationId: _.constant(vm.organizationOverview.org.id),
                    group: _.constant(group)
                },
                windowClass: 'pivot_theme',
                size: 'sm'
            });
        }
    }
})();
