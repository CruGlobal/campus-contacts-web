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

    function organizationalStatsController ($scope, periodService, reportsService) {
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
            return reportsService.getInteractionCount(vm.report, interactionTypeId);
        }
    }
})();
