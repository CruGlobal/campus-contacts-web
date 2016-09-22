(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .controller('DashboardController', DashboardController);

    function DashboardController ($window, $location, $scope, loggedInPerson, periodService) {
        var vm = this;

        $scope.$on('$locationChangeSuccess', function () {
            var path = $location.path();
            if (path === '/ministries') {
                vm.mode = 'organizations';
            } else if (path === '/people') {
                vm.mode = 'people';
            }
        });

        vm.mode = 'people';
        vm.loggedInPerson = loggedInPerson;
        vm.getPeriod = periodService.getPeriod;
        vm.$onInit = activate;

        function activate () {
            loggedInPerson.load();
        }
    }
})();
