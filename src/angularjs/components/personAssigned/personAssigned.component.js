import template from './personAssigned.html';
import './personAssigned.scss';

angular.module('missionhubApp').component('personAssigned', {
  controller: personAssignedController,
  require: {
    personTab: '^personPage',
  },
  template: template,
});

function personAssignedController(personAssignedService) {
  var vm = this;
  vm.assignments = null;
  vm.$onInit = activate;

  function activate() {
    personAssignedService
      .getAssigned(vm.personTab.person, vm.personTab.organizationId)
      .then(function(assignments) {
        vm.assignments = assignments;
      });
  }
}
