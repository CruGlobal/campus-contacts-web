editGroupController.$inject = [
  'groupsService',
  'editGroupService',
  'tFilter',
  '_',
];
import template from './editGroup.html';
import './editGroup.scss';

angular.module('missionhubApp').component('editGroup', {
  controller: editGroupController,
  bindings: {
    resolve: '<',
    close: '&',
    dismiss: '&',
  },
  template: template,
});

function editGroupController(groupsService, editGroupService, tFilter, _) {
  var vm = this;

  vm.title = null;
  vm.saving = false;
  vm.meetingFrequencyOptions = ['weekly', 'monthly', 'sporadically'];
  vm.weekDayOptions = _.range(0, 7).map(function(day) {
    return { value: day, label: tFilter('date.day_names.' + day) };
  });
  vm.monthDayOptions = _.range(1, 32).map(function(day) {
    return { value: day, label: day.toString() };
  });

  vm.valid = valid;
  vm.save = save;
  vm.cancel = cancel;

  vm.$onInit = activate;

  function activate() {
    vm.orgId = vm.resolve.organizationId;
    var groupTemplate = groupsService.getGroupTemplate(vm.orgId);
    vm.group = _.clone(vm.resolve.group || groupTemplate);
    vm.leaders = groupsService.getMembersWithRole(vm.group, 'leader');

    // The uib-timepicker needs the start and end times to be Date instances
    // Default the start and end times to the values set on their default values in a new group template
    vm.startTimeDate = groupsService.timeToDate(
      vm.group.start_time || groupTemplate.start_time,
    );
    vm.endTimeDate = groupsService.timeToDate(
      vm.group.end_time || groupTemplate.end_time,
    );

    // Track the meeting time when it is a day of the week and when it is a day of the month separately
    vm.meetingDayOfWeek =
      vm.group.meets === 'weekly' ? vm.group.meeting_day : 0;
    vm.meetingDayOfMonth =
      vm.group.meets === 'monthly' ? vm.group.meeting_day : 1;

    vm.title = vm.group.id ? 'groups.edit.edit_group' : 'groups.new.new_group';
  }

  function valid() {
    return editGroupService.isGroupValid(vm.group);
  }

  function save() {
    vm.saving = true;

    // Update the start and end times with the uib-timepicker values
    vm.group.start_time = groupsService.dateToTime(vm.startTimeDate);
    vm.group.end_time = groupsService.dateToTime(vm.endTimeDate);

    // Copy the meeting time to the group
    if (vm.group.meets === 'weekly') {
      vm.group.meeting_day = vm.meetingDayOfWeek;
    } else if (vm.group.meets === 'monthly') {
      vm.group.meeting_day = vm.meetingDayOfMonth;
    } else if (vm.group.meets === 'sporadically') {
      vm.group.meeting_day = null;
      vm.group.start_time = null;
      vm.group.end_time = null;
    }

    groupsService
      .saveGroup(vm.group, vm.leaders)
      .then(function(newGroup) {
        vm.close({ $value: newGroup });
      })
      .catch(function() {
        vm.saving = false;
      });
  }

  function cancel() {
    vm.dismiss();
  }
}
