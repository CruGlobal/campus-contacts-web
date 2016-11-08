(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('contactActivity', {
            controller: contactActivityController,
            require: {
                contactTab: '^organizationOverviewContact'
            },
            templateUrl: '/assets/angular/components/contactActivity/contactActivity.html'
        });

    function contactActivityController (interactionsService, reportsService, periodService) {
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

            var organizationId = vm.contactTab.organizationId;
            var personId = vm.contactTab.contact.id;
            reportsService.loadPersonReport(organizationId, personId).then(function (report) {
                vm.report = report;
            });
        }

        function getInteractionCount (interactionTypeId) {
            return reportsService.getInteractionCount(vm.report, interactionTypeId);
        }
    }
})();
