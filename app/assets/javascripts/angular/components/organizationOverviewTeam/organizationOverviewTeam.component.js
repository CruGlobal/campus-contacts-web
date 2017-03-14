(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewTeam', {
            controller: organizationOverviewTeamController,
            bindings: {
                org: '<'
            },
            templateUrl: '/assets/angular/components/organizationOverviewTeam/organizationOverviewTeam.html'
        });

    function organizationOverviewTeamController (organizationOverviewTeamService, ProgressiveListLoader) {
        var vm = this;
        vm.team = [];
        vm.loadTeamPage = loadTeamPage;

        var listLoader = new ProgressiveListLoader('person');

        function loadTeamPage () {
            if (vm.busy) {
                return;
            }
            vm.busy = true;

            return organizationOverviewTeamService.loadOrgTeam(vm.org, listLoader)
                .then(function (resp) {
                    vm.team = resp.list;
                    vm.loadedAll = resp.loadedAll;
                })
                .finally(function () {
                    vm.busy = false;
                });
        }
    }
})();
