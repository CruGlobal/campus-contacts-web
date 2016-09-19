(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('preferencesPage', {
            controller: preferencesPageController,
            templateUrl: '/assets/angular/components/preferencesPage/preferencesPage.html',
            bindings: {}
        });

    function preferencesPageController (preferencesPageService) {
        var vm = this;

        vm.$onInit = activate;

        function activate () {
            readPreferences();
        }

        function readPreferences() {
            vm.preferences = preferencesPageService.readPreferences();
        }

        function updatePreferences() {
            preferencesPageService.updatePreferences(vm.preferences);
        }
    }
})();
