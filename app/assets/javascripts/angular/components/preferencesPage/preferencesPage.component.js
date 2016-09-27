(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('preferencesPage', {
            controller: preferencesPageController,
            templateUrl: '/assets/angular/components/preferencesPage/preferencesPage.html',
            bindings: {}
        });

    function preferencesPageController (preferencesPageService, languageService, loggedInPerson) {
        var vm = this;
        vm.supportedLanguages = [];

        vm.$onInit = activate;

        function activate () {
            readPreferences();
            vm.supportedLanguages = loadLanguages();
        }

        function readPreferences() {
            vm.preferences = preferencesPageService.readPreferences();
        }

        function updatePreferences() {
            preferencesPageService.updatePreferences(vm.preferences);
        }

        function loadLanguages () {
            return languageService.loadLanguages();
        }
    }
})();
