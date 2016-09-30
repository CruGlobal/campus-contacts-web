(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('preferencesPage', {
            controller: preferencesPageController,
            templateUrl: '/assets/angular/components/preferencesPage/preferencesPage.html'
        });

    function preferencesPageController (preferencesPageService, languageService, $location) {

        var vm = this;

        vm.supportedLanguages = [];
        vm.contactMoved = true;
        vm.contactAssigned = true;
        vm.weeklyDigest = true;
        vm.preferences = null;
        vm.selectedLanguage = null;
        vm.selectedLanguageChanged = false;

        vm.$onInit = activate;

        function activate () {
            vm.readPreferences();
            vm.supportedLanguages = languageService.loadLanguages();;
        }

        function unsubscribeWeeklyDigest () {
             if($location.search()["ministry-digest-unsubscribe"] === true){
                 vm.weeklyDigest = false;
                 vm.saveUserPreferences();
             }
        }

        vm.readPreferences = function readPreferences () {
             preferencesPageService.readPreferences().then(function (me) {
                 vm.preferences = me;
                 mapUserPreferences(vm.preferences);
                 unsubscribeWeeklyDigest();
                 vm.selectedLanguageChanged = false;
            });
        }

        function mapUserPreferences (userPreferences) {
            vm.timeZone = userPreferences.user.time_zone;
            if(userPreferences.user.language !== null) {
                angular.forEach(vm.supportedLanguages, function (value) {
                    if(value.abbreviation === userPreferences.user.language)
                        vm.selectedLanguage = value;
                });
            }

            if(userPreferences.user.notification_settings !== null){
                var notificationPreferences = JSON.parse(userPreferences.user.notification_settings);
                vm.contactMoved = notificationPreferences.contactMoved;
                vm.contactAssigned = notificationPreferences.contactAssigned;
                vm.weeklyDigest = notificationPreferences.weeklyDigest;
            }
        }

        vm.saveUserPreferences = function updatePreferences () {

            var notificationPreferences = {
                contactMoved: vm.contactMoved,
                contactAssigned: vm.contactAssigned,
                weeklyDigest: vm.weeklyDigest
            };

            vm.preferences.user.notification_settings = JSON.stringify(notificationPreferences);
            vm.preferences.user.language = vm.selectedLanguage !== null ? vm.selectedLanguage.abbreviation : null;

            preferencesPageService.updatePreferences(vm.preferences.user.serialize());
            vm.selectedLanguageChanged = true;
        }

    }
})();
