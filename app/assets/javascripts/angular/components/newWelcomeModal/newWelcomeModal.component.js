(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('newWelcomeModal', {
            controller: newWelcomeModalController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('newWelcomeModal');
            },
            bindings: {
                dismiss: '&'
            }
        });

    function newWelcomeModalController ($rootScope, loggedInPerson) {
        var vm = this;

        vm.sending = false;

        vm.accept = accept;

        function accept () {
            vm.sending = true;
            loggedInPerson.updatePreferences({ beta_mode: true })
                .then(function () {
                    $rootScope.legacyNavigation = false;
                })
                .then(vm.dismiss)
                .catch(function () {
                    vm.sending = false;
                });
        }
    }
})();
