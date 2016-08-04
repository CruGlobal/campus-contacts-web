(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('reportPeriod', {
            controller: reportPeriodController,
            bindings: {
                period: '<',
                onUpdate: '&'
            },
            templateUrl: '/templates/reportPeriod.html'
        });

    function reportPeriodController () {
        var vm = this;
        vm.periods = [
            {label: '1w', period: 'P1W'},
            {label: '1m', period: 'P1M'},
            {label: '3m', period: 'P3M'},
            {label: '6m', period: 'P6M'},
            {label: '1y', period: 'P1Y'}
        ];
    }
})();
