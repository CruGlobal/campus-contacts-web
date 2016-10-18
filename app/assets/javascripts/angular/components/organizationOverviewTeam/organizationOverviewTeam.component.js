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

    function organizationOverviewTeamController (organizationOverviewTeamService) {
        var vm = this;
        vm.team = null;
        vm.loadTeamPage = loadTeamPage;

        function loadTeamPage (page) {
            return organizationOverviewTeamService.loadOrgTeam(vm.org, page);
        }
    }
})();
