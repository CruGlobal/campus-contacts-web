organizationOverviewSuborgsController.$inject = [
  '$scope',
  '$state',
  '$log',
  'reportsService',
  'periodService',
  'ProgressiveListLoader',
  'organizationOverviewSuborgsService',
];
import template from './organizationOverviewSuborgs.html';

angular.module('missionhubApp').component('organizationOverviewSuborgs', {
  controller: organizationOverviewSuborgsController,
  bindings: {
    $transition$: '<',
  },
  require: {
    organizationOverview: '^',
  },
  template: template,
});

function organizationOverviewSuborgsController(
  $scope,
  $state,
  $log,
  reportsService,
  periodService,
  ProgressiveListLoader,
  organizationOverviewSuborgsService,
) {
  var vm = this;
  vm.loadedAll = false;
  vm.subOrgs = [];
  vm.loadSubOrgsPage = loadSubOrgsPage;

  var listLoader = new ProgressiveListLoader({
    modelType: 'organization',
    errorMessage: 'error.messages.organization_overview_suborgs.load_org_chunk',
  });

  vm.$onInit = activate;

  function activate() {
    periodService.subscribe($scope, loadReports);
  }

  function loadSubOrgsPage() {
    if (vm.busy) {
      return;
    }
    vm.busy = true;

    return organizationOverviewSuborgsService
      .loadOrgSubOrgs(vm.organizationOverview.org, listLoader)
      .then(function(resp) {
        vm.subOrgs = resp.list;
        vm.loadedAll = resp.loadedAll;
        loadReports();

        // TODO: this seems to have been broken somehow, probably through a UI Router upgrade
        // If this component was implicitly navigated to since it is the default tab and the org has no sub
        // orgs, then navigate to the people tab instead. If this component was explicitly navigated to,
        // such as by the user directly clicking on its tab, then do not perform that navigation.
        if (vm.$transition$.redirectedFrom() && vm.subOrgs.length === 0) {
          $state.go('^.people');
        }
      })
      .finally(function() {
        vm.busy = false;
      });
  }

  function loadReports() {
    reportsService.loadOrganizationReports(vm.subOrgs).catch(function(error) {
      $log.error('Error loading organization reports', error);
    });
  }
}
