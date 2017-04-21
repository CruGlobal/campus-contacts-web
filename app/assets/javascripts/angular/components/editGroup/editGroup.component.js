(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('editGroup', {
            controller: editGroupController,
            bindings: {
                resolve: '<',
                close: '&',
                dismiss: '&'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('editGroup');
            }
        });

    function editGroupController (groupsService, editGroupService, moment, _) {
        var vm = this;

        vm.title = null;
        vm.saving = false;
        vm.meetingFrequencyOptions = ['weekly', 'monthly', 'sporadically'];
        vm.dayOptions = _.range(1, 32);

        vm.valid = valid;
        vm.save = save;
        vm.cancel = cancel;

        vm.$onInit = activate;

        function activate () {
            vm.group = _.clone(vm.resolve.group || editGroupService.getGroupTemplate(vm.resolve.organizationId));

            // The uib-timepicker needs the start and end times to be Date instances
            vm.group.start_time_date = editGroupService.timeToDate(vm.group.start_time);
            vm.group.end_time_date = editGroupService.timeToDate(vm.group.end_time);

            vm.title = vm.group.id ? 'groups.edit.edit_group' : 'groups.new.new_group';
        }

        function valid () {
            return editGroupService.isGroupValid(vm.group);
        }

        function save () {
            vm.saving = true;

            // Update the start and end times with the uib-timepicker values
            vm.group.start_time = editGroupService.dateToTime(vm.group.start_time_date);
            vm.group.end_time = editGroupService.dateToTime(vm.group.end_time_date);

            editGroupService.saveGroup(vm.group)
                .then(function (newGroup) {
                    vm.close({ $value: newGroup });
                })
                .catch(function () {
                    vm.saving = false;
                });
        }

        function cancel () {
            vm.dismiss();
        }
    }
})();
