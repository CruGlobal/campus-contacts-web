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
        vm.preferences = null;
        vm.selectedLanguage = null;

        vm.$onInit = activate;

        function activate () {
            readPreferences();
            vm.supportedLanguages = loadLanguages();
        }

        function readPreferences() {
             preferencesPageService.readPreferences().then(function (me) {
                 vm.preferences = me;
            });
        }

        vm.saveUserPreferences = function updatePreferences() {

            var preferences = {
                contactMoved: vm.contactMoved,
                contactAssigned: vm.contactAssigned,
                weeklyDigest: vm.weeklyDigest
            };

            vm.preferences.user.notification_settings = JSON.stringify(preferences);
            vm.preferences.user.terms_acceptance_date = new Date();

            if(vm.selectedLanguage !== null)
                vm.preferences.user.language = vm.selectedLanguage.abbreviation;

            var userData = {
                data: {
                    type: 'user',
                    attributes: vm.preferences.user
                }
            };

            preferencesPageService.updatePreferences(userData);
        }

        function loadLanguages () {
            return languageService.loadLanguages();
        }

    }
})();
