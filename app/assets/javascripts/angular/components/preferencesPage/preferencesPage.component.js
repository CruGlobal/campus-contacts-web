(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('preferencesPage', {
            controller: preferencesPageController,
            templateUrl: '/assets/angular/components/preferencesPage/preferencesPage.html'
        });

    function preferencesPageController (preferencesPageService, languageService, $location, _) {
        var vm = this;

        vm.supportedLanguages = [];
        vm.contactMoved = true;
        vm.contactAssigned = true;
        vm.weeklyDigest = true;
        vm.selectedLanguageChanged = false;

        vm.$onInit = activate;

        function activate () {
            readPreferences();
            vm.supportedLanguages = languageService.loadLanguages();
        }

        function unsubscribeWeeklyDigest () {
             if($location.search()["ministry-digest-unsubscribe"] === true) {
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
            vm.timeZone = user.timezone;
            if(user.language !== null) {
                vm.selectedLanguage = _.find(vm.supportedLanguages, { abbreviation: user.language });
            }

            if(user.notification_settings !== null) {
                vm.contactMoved = user.notification_settings.contact_moved;
                vm.contactAssigned = user.notification_settings.contact_assigned;
                vm.weeklyDigest = user.notification_settings.weekly_digest;
            }
        }

        vm.saveUserPreferences = function updatePreferences () {
            vm.user.notification_settings = {
                contact_moved: vm.contactMoved,
                contact_assigned: vm.contactAssigned,
                weekly_digest: vm.weeklyDigest
            };

            if(vm.selectedLanguage) {
                vm.selectedLanguageChanged = vm.user.language != vm.selectedLanguage.abbreviation;
                vm.user.language = vm.selectedLanguage.abbreviation;
            }

            preferencesPageService.updatePreferences(vm.user.serialize());
        }
    }
})();
