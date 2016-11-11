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
            templateUrl: '/assets/angular/components/editGroup/editGroup.html'
        });

    function editGroupController (groupsService, _) {
        var vm = this;

        vm.title = 'groups.new.new_group';
        vm.saving = false;
        vm.meetingFrequencyOptions = ['weekly', 'monthly', 'sporadically'];
        vm.dayOptions = _.range(1, 32);

        vm.valid = valid;
        vm.save = save;
        vm.cancel = cancel;

        vm.$onInit = activate;

        function activate () {
            vm.group = vm.resolve.group;
            if(!vm.group) {
                createBlankGroup()
            }
        }

        function valid () {
            return vm.group.name && vm.group.location;
        }

        function createBlankGroup () {
            var from = new Date(21600000 + getTimeOffset());
            var to = new Date(25200000 + getTimeOffset());
            vm.group = {
                name: '',
                location: '',
                meets: 'weekly',
                meeting_day: '0',
                start_time: from,
                end_time: to
            }
        }

        function save () {
            var groupParams = _.clone(vm.group);

            groupParams.start_time = (groupParams.start_time.getTime() - getTimeOffset()) / 1000;
            groupParams.end_time = (groupParams.end_time.getTime() - getTimeOffset()) / 1000;

            if(vm.group.meets === 'sporadically') {
                vm.group.meeting_day = null;
                vm.group.start_time = null;
                vm.group.end_time = null;
            }
            // save the group
            vm.saving = true;
            groupsService.createGroup(groupParams, vm.resolve.organizationId)
                .then(function (newGroup) {
                    vm.close({ $value: newGroup });
                })
                .catch(function () {
                    vm.saving = false;
                })
        }

        function cancel () {
            vm.dismiss();
        }

        function getTimeOffset () {
            return (new Date().getTimezoneOffset()) * 60000;
        }
    }
})();
