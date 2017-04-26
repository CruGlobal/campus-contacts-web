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

    function organizationOverviewGroupsController ($uibModal, groupsService, tFilter, confirmModalService, _) {
        var vm = this;
        vm.addGroup = addGroup;
        vm.editGroup = editGroup;
        vm.deleteGroup = deleteGroup;

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

        function deleteGroup (group) {
            confirmModalService.create(tFilter('groups.confirm_delete_group', { group_name: group.name }))
                .then(function () {
                    return groupsService.deleteGroup(group);
                })
                .then(function () {
                    _.pull(vm.organizationOverview.org.groups, group);
                });
        }
    }
})();
