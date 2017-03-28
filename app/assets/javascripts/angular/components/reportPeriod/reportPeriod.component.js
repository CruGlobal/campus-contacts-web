(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('reportPeriod', {
            controller: reportPeriodController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('reportPeriod');
            }
        });

    function reportPeriodController (periodService) {
        var vm = this;
        vm.periods = periodService.getPeriods();
        vm.getPeriod = periodService.getPeriod;
        vm.setPeriod = periodService.setPeriod;
    }
})();
