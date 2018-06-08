import template from './organizationOverviewTeam.html';

angular.module('missionhubApp').component('organizationOverviewTeam', {
  controller: organizationOverviewTeamController,
  require: {
    organizationOverview: '^',
  },
  template: template,
});

function organizationOverviewTeamController(
  organizationOverviewTeamService,
  ProgressiveListLoader,
  reportsService,
  periodService,
  $scope,
) {
  var vm = this;
  vm.team = [];
  vm.loadTeamPage = loadTeamPage;

  var listLoader = new ProgressiveListLoader({
    modelType: 'person',
    errorMessage: 'error.messages.organization_overview_team.load_team_chunk',
  });

  vm.$onInit = activate;

  function activate() {
    periodService.subscribe($scope, function() {
      loadTeamReports([vm.organizationOverview.org.id], vm.team);
    });
  }

  function loadTeamPage() {
    if (vm.busy) {
      return;
    }
    vm.busy = true;

    return organizationOverviewTeamService
      .loadOrgTeam(vm.organizationOverview.org, listLoader)
      .then(function(resp) {
        vm.team = resp.list;
        vm.loadedAll = resp.loadedAll;
        return loadTeamReports([vm.organizationOverview.org.id], vm.team);
      })
      .finally(function() {
        vm.busy = false;
      });
  }

  function loadTeamReports(orgIds, team) {
    return reportsService.loadMultiplePeopleReports(orgIds, team);
  }
}
