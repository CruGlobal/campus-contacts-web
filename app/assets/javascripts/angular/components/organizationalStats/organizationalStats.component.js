import template from './organizationalStats.html';
import './organizationalStats.scss';

angular.module('campusContactsApp').component('organizationalStats', {
  bindings: {
    org: '<',
  },
  controller: organizationalStatsController,
  template,
});

function organizationalStatsController($scope, periodService, reportsService) {
  const vm = this;

  vm.getInteractionCount = getInteractionCount;

  vm.$onInit = activate;

  function activate() {
    periodService.subscribe($scope, lookupReport);
    lookupReport();
  }

  function lookupReport() {
    vm.report = reportsService.lookupOrganizationReport(vm.org.id);
  }

  function getInteractionCount(interactionTypeId) {
    return reportsService.getInteractionCount(vm.report, interactionTypeId);
  }
}
