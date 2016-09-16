(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .controller('DashboardController', DashboardController);

    function DashboardController ($window, loggedInPerson) {
        var vm = this;

        vm.updatePeriod = updatePeriod;

        vm.loggedInPerson = loggedInPerson;
        vm.$onInit = activate;

        function activate () {
            if($window.localStorage) {
                var value = $window.localStorage.getItem('reportPeriod');
                vm.period = (!value) ? 'P3M' : value;
            } else {
                vm.period = 'P3M';
            }
        }

        function updatePeriod (period) {
            vm.period = period;
            if($window.localStorage) {
                $window.localStorage.setItem('reportPeriod', period);
            }
        }
    }
})();
