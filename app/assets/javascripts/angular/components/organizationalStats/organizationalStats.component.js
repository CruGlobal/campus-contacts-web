(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationalStats', {
            bindings: {
                org: '<'
            },
            controller: organizationalStatsController,
            templateUrl: '/assets/angular/components/organizationalStats/organizationalStats.html'
        });

    function organizationalStatsController ($scope, periodService, reportsService, _) {
        var vm = this;

        vm.getInteractionCount = getInteractionCount;

        vm.$onInit = activate;

        function activate () {
            periodService.subscribe($scope, lookupReport);
            lookupReport();
        }

        function lookupReport () {
            vm.report = reportsService.lookupOrganizationReport(vm.org.id);
        }

        function getInteractionCount (interactionTypeId) {
            var interaction = _.find(vm.report.interactions, { interaction_type_id: interactionTypeId });
            return angular.isDefined(interaction) ? interaction.interaction_count : '-';
        }
    }
})();
