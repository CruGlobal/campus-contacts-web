(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .controller('DashboardController', DashboardController);

    function DashboardController (loggedInPerson, periodService) {
        var vm = this;

        vm.editOrganizations = false;
        vm.getPeriod = periodService.getPeriod;
        vm.loggedInPerson = loggedInPerson;
        vm.$onInit = activate;

        function activate () {
            loggedInPerson.load();
        }
    }
})();
