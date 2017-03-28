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

            return organizationOverviewTeamService.loadOrgTeam(vm.organizationOverview.org, listLoader)
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
