(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('nav', {
            controller: navController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('nav');
            }
        });

    function navController (state, loggedInPerson) {
        var vm = this;

        vm.state = state;
        vm.loggedInPerson = loggedInPerson;
    }
})();
