(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewTeam', {
            controller: organizationOverviewTeamController,
            require: {
                organizationOverview: '^'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('organizationOverviewTeam');
            }
        });

    function organizationOverviewTeamController ($log, _, organizationOverviewTeamService, ProgressiveListLoader,
                                                 myPeopleDashboardService) {
        var vm = this;
        vm.team = [];
        vm.loadTeamPage = loadTeamPage;

        var listLoader = new ProgressiveListLoader({
            modelType: 'person',
            errorMessage: 'error.messages.organization_overview_team.load_team_chunk'
        });

        function loadTeamPage () {
            if (vm.busy) {
                return;
            }
            vm.busy = true;

            return organizationOverviewTeamService.loadOrgTeam(vm.organizationOverview.org, listLoader)
                .then(function (resp) {
                    vm.team = resp.list;
                    loadReports(vm.team);
                    vm.loadedAll = resp.loadedAll;
                })
                .finally(function () {
                    vm.busy = false;
                });
        }

        function loadReports (team) {
            var peopleIds = _.map(team, 'id');

            var peopleReportParams = {
                organization_ids: [vm.organizationOverview.org.id],
                people_ids: peopleIds
            };

            myPeopleDashboardService.loadPeopleReports(peopleReportParams)
                .catch(function (error) {
                    $log.error('Error loading team people reports', error);
                });
        }
    }
})();
