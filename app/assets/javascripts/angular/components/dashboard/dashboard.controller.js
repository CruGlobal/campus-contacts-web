(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .controller('DashboardController', DashboardController);

    function DashboardController (loggedInPerson, periodService, $uibModal) {
        var vm = this;

        vm.editOrganizations = false;
        vm.getPeriod = periodService.getPeriod;
        vm.loggedInPerson = loggedInPerson;
        vm.$onInit = activate;

        function activate () {
            loggedInPerson.loadOnce().then(function (me) {
                if (me.user.beta_mode === null) {
                    $uibModal.open({
                        component: 'betaWelcomeModal',
                        resolve: {},
                        windowClass: 'pivot_theme',
                        size: 'sm'
                    });
                }
            });
        }
    }
})();
