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
        vm.user = null;
        vm.selectedLanguage = null;
        vm.selectedLanguageChanged = false;

        vm.$onInit = activate;

        function activate () {
            readPreferences();
            vm.supportedLanguages = languageService.loadLanguages();
        }

        function unsubscribeWeeklyDigest () {
             if($location.search()["ministry-digest-unsubscribe"] === true){
                 vm.weeklyDigest = false;
                 vm.saveUserPreferences();
             }
        }

        function readPreferences () {
             preferencesPageService.readPreferences().then(function (me) {
                 vm.user = me.user;
                 mapUserPreferences(vm.user);
                 unsubscribeWeeklyDigest();
            });
        }

        function mapUserPreferences (user) {
            vm.timeZone = user.time_zone;
            if(user.language !== null) {
                angular.forEach(vm.supportedLanguages, function (value) {
                    if(value.abbreviation === user.language)
                        vm.selectedLanguage = value;
                });
            }

            if(user.notification_settings !== null){
                var notificationPreferences = user.notification_settings;
                vm.contactMoved = notificationPreferences.contact_moved;
                vm.contactAssigned = notificationPreferences.contact_assigned;
                vm.weeklyDigest = notificationPreferences.weekly_digest;
            }
        }

        vm.saveUserPreferences = function updatePreferences () {
            var notificationPreferences = {
                contact_moved: vm.contactMoved,
                contact_assigned: vm.contactAssigned,
                weekly_digest: vm.weeklyDigest
            };
            var languageChanging = false;

            vm.user.notification_settings = notificationPreferences;
            if(vm.selectedLanguage) {
                languageChanging = vm.user.language != vm.selectedLanguage.abbreviation;
                vm.user.language = vm.selectedLanguage.abbreviation;
            }

            preferencesPageService.updatePreferences(vm.user.serialize());
            if(languageChanging)
                vm.selectedLanguageChanged = true;
        }
    }
})();
