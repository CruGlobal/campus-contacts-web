(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .controller('DashboardController', DashboardController);

    function DashboardController ($window, loggedInPerson, periodService) {
        var vm = this;

        vm.editOrganizations = false;
        vm.getPeriod = periodService.getPeriod;
        // Look for a query-string parameter called "beta"
        vm.showSecretNavigation = $window.localStorage.getItem('beta') !== null ||
            $window.location.search.slice(1).split('&').some(function (part) { return /^beta=/.test(part) });
        vm.$onInit = activate;

        function activate () {
            loggedInPerson.load();
        }
    }
})();
