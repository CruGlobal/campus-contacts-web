import template from './ministryViewGroup.html';
import './ministryViewGroup.scss';

angular.module('missionhubApp').component('ministryViewGroup', {
    controller: ministryViewGroupController,
    template: template,
    bindings: {
        group: '<',
    },
});

function ministryViewGroupController(
    $scope,
    $uibModal,
    confirmModalService,
    tFilter,
    groupsService,
    ministryViewGroupService,
    _,
) {
    var vm = this;

    vm.getLeaders = getLeaders;
    vm.openGroup = openGroup;
    vm.editGroup = editGroup;
    vm.deleteGroup = deleteGroup;
    vm.$onInit = activate;

    function activate() {
        $scope.$watchGroup(
            [
                '$ctrl.group.meets',
                '$ctrl.group.meeting_day',
                '$ctrl.group.start_time',
                '$ctrl.group.end_time',
            ],
            function() {
                vm.meetingTime = ministryViewGroupService.formatMeetingTime(
                    vm.group,
                );
            },
        );
    }

    function getLeaders() {
        return groupsService.getMembersWithRole(vm.group, 'leader');
    }

    function openGroup() {
        $uibModal.open({
            component: 'groupMembersModal',
            resolve: {
                group: _.constant(vm.group),
            },
            windowClass: 'pivot_theme',
            size: 'md',
        });
    }

    function editGroup() {
        $uibModal.open({
            component: 'editGroup',
            resolve: {
                organizationId: _.constant(vm.group.organization.id),
                group: _.constant(vm.group),
            },
            windowClass: 'pivot_theme',
            size: 'md',
        });
    }

    function deleteGroup() {
        confirmModalService
            .create(
                tFilter('groups.confirm_delete_group', {
                    group_name: vm.group.name,
                }),
            )
            .then(function() {
                return groupsService.deleteGroup(vm.group);
            });
    }
}
