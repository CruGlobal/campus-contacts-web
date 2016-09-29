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
                 mapUserPreferences(vm.preferences);
            });
        }

        function mapUserPreferences(userPreferences) {
            if(userPreferences.user.language !== null) {
                angular.forEach(vm.supportedLanguages, function (value) {
                    if(value.abbreviation === userPreferences.user.language)
                        vm.selectedLanguage = value;
                });
            }

            if(userPreferences.user.notification_Settings !== null)
            {
                var notificationPreferences = JSON.parse(userPreferences.user.notification_settings);
                vm.contactMoved = notificationPreferences.contactMoved;
                vm.contactAssigned = notificationPreferences.contactAssigned;
                vm.weeklyDigest = notificationPreferences.weeklyDigest;
            }
        }

        vm.saveUserPreferences = function updatePreferences() {

            var notificationPreferences = {
                contactMoved: vm.contactMoved,
                contactAssigned: vm.contactAssigned,
                weeklyDigest: vm.weeklyDigest
            };

            vm.preferences.user.notification_settings = JSON.stringify(notificationPreferences);
            vm.preferences.user.language = vm.selectedLanguage !== null ? vm.selectedLanguage.abbreviation : null;

            preferencesPageService.updatePreferences(vm.preferences.user.serialize());
        }

        function loadLanguages () {
            return languageService.loadLanguages();
        }

    }
})();
