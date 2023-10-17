import template from './personAssigned.html';
import './personAssigned.scss';

angular.module('campusContactsApp').component('personAssigned', {
  controller: personAssignedController,
  require: {
    personTab: '^personPage',
  },
  template,
});

function personAssignedController(personAssignedService) {
  const vm = this;
  vm.assignments = null;
  vm.$onInit = activate;

  function activate() {
    personAssignedService.getAssigned(vm.personTab.person, vm.personTab.organizationId).then(function (assignments) {
      vm.assignments = assignments;
    });
  }
}
