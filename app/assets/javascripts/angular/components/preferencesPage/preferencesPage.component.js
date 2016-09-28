(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('preferencesPage', {
            controller: preferencesPageController,
            templateUrl: '/assets/angular/components/preferencesPage/preferencesPage.html',
            bindings: {
                period: '<',
                onUpdate: '&'
            }
        });

    function preferencesPageController (preferencesPageService, languageService) {

        var vm = this;

        vm.supportedLanguages = [];
        vm.contactMoved = true;
        vm.contactAssigned = true;
        vm.weeklyDigest = true;

        vm.$onInit = activate;

        function activate () {
            readPreferences();
            vm.supportedLanguages = loadLanguages();
        }

        function readPreferences() {
            vm.preferences = preferencesPageService.readPreferences();
            console.log(vm.preferences);
        };

        vm.saveUserPreferences = function updatePreferences() {

            vm.preferences = {
                contactMoved: vm.contactMoved,
                contactAssigned: vm.contactAssigned,
                weeklyDigest: vm.weeklyDigest,
                language: vm.selectedLanguage
            };

            console.log(vm.preferences);

            var promise = preferencesPageService.updatePreferences(vm.preferences);
            promise.then(function (response) {
                //Save the new values in Json
            });
        };

        function loadLanguages () {
            return languageService.loadLanguages();
        };

    }
})();
