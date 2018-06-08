import template from './personActivity.html';
import './personActivity.scss';

angular.module('missionhubApp').component('personActivity', {
  controller: personActivityController,
  require: {
    personTab: '^personPage',
  },
  template: template,
});

function personActivityController(
  interactionsService,
  reportsService,
  periodService,
) {
  var vm = this;
  vm.report = null;
  vm.period = null;
  vm.getInteractionCount = getInteractionCount;
  vm.$onInit = activate;
  vm.setPeriod = setPeriod;

  function activate() {
    vm.interactionTypes = interactionsService
      .getInteractionTypes()
      .filter(function(interactionType) {
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

    var organizationId = vm.personTab.organizationId;
    var personId = vm.personTab.person.id;
    reportsService
      .loadPersonReport(organizationId, personId)
      .then(function(report) {
        vm.report = report;
      });
  }

  function getInteractionCount(interactionTypeId) {
    return reportsService.getInteractionCount(vm.report, interactionTypeId);
  }
}
