import template from './personActivity.html';
import './personActivity.scss';

angular.module('campusContactsApp').component('personActivity', {
  controller: personActivityController,
  require: {
    personTab: '^personPage',
  },
  template,
});

function personActivityController(interactionsService, reportsService, periodService) {
  const vm = this;
  vm.report = null;
  vm.period = null;
  vm.getInteractionCount = getInteractionCount;
  vm.$onInit = activate;
  vm.setPeriod = setPeriod;

  function activate() {
    vm.interactionTypes = interactionsService.getInteractionTypes().filter(function (interactionType) {
      return interactionType.id !== 1;
    });
    vm.periods = periodService.getPeriods();
    updatePeriod();
  }

  function setPeriod(period) {
    periodService.setPeriod(period);
    updatePeriod();
  }

  function updatePeriod() {
    vm.period = periodService.getPeriod();

    const organizationId = vm.personTab.organizationId;
    const personId = vm.personTab.person.id;
    reportsService.loadPersonReport(organizationId, personId).then(function (report) {
      vm.report = report;
    });
  }

  function getInteractionCount(interactionTypeId) {
    return reportsService.getInteractionCount(vm.report, interactionTypeId);
  }
}
