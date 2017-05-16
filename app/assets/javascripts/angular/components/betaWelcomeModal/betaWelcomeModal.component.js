(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('betaWelcomeModal', {
            controller: betaWelcomeModalController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('betaWelcomeModal');
            },
            bindings: {
                dismiss: '&'
            }
        });

    function betaWelcomeModalController ($rootScope, loggedInPerson) {
        var vm = this;

        vm.sending = false;

        vm.tryBeta = tryBeta;
        vm.noBeta = noBeta;

        function updateBeta (enabled) {
            vm.sending = true;
            loggedInPerson.updatePreferences({ beta_mode: enabled })
                .then(function () {
                    $rootScope.betaMode = enabled;
                })
                .then(vm.dismiss)
                .catch(function () {
                    vm.sending = false;
                });
        }

        function tryBeta () {
            updateBeta(true);
        }

        function noBeta () {
            updateBeta(false);
        }
    }
})();
