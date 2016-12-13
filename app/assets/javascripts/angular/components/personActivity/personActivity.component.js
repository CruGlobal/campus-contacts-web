(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('personActivity', {
            controller: personActivityController,
            require: {
                personTab: '^personPage'
            },
            templateUrl: '/assets/angular/components/personActivity/personActivity.html'
        });

    function personActivityController (interactionsService, reportsService, periodService) {
        var vm = this;
        vm.interactionTypes = interactionsService.getInteractionTypes().filter(function (interactionType) {
            return interactionType.id !== 1;
        });
        vm.report = null;
        vm.periods = periodService.getPeriods();
        vm.period = null;
        vm.getInteractionCount = getInteractionCount;
        vm.$onInit = activate;
        vm.setPeriod = setPeriod;

        function activate () {
            updatePeriod();
        }

        function setPeriod (period) {
            periodService.setPeriod(period);
            updatePeriod();
        }

        function updatePeriod () {
            vm.period = periodService.getPeriod();

            var organizationId = vm.personTab.organizationId;
            var personId = vm.personTab.person.id;
            reportsService.loadPersonReport(organizationId, personId).then(function (report) {
                vm.report = report;
            });
        }

        function getInteractionCount (interactionTypeId) {
            return reportsService.getInteractionCount(vm.report, interactionTypeId);
        }
    }
})();
