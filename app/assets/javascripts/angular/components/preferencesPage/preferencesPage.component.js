import template from './preferencesPage.html';
import './preferencesPage.scss';

angular.module('missionhubApp').component('preferencesPage', {
    controller: preferencesPageController,
    template: template,
});

function preferencesPageController(
    $rootScope,
    preferencesPageService,
    languageService,
    _,
    nativeLocation,
) {
    var vm = this;

    vm.supportedLanguages = [];
    vm.personMoved = true;
    vm.personAssigned = true;
    vm.weeklyDigest = true;
    vm.selectedLanguageChanged = false;

    vm.reload = reload;
    vm.updatePreferences = updatePreferences;

    vm.$onInit = activate;

    function activate() {
        readPreferences();
        vm.supportedLanguages = languageService.loadLanguages();
    }

    function unsubscribeWeeklyDigest() {
        if (nativeLocation.search === '?ministry-digest-unsubscribe') {
            vm.weeklyDigest = false;
            updatePreferences().then(function() {
                nativeLocation.search = '';
            });
        }
    }

    function readPreferences() {
        preferencesPageService.readPreferences().then(function(me) {
            vm.user = me.user;
            mapUserPreferences(vm.user);
            unsubscribeWeeklyDigest();
        });
    }

    function mapUserPreferences(user) {
        vm.timeZone = user.timezone;
        if (user.language !== null) {
            vm.selectedLanguage = _.find(vm.supportedLanguages, {
                abbreviation: user.language,
            });
        }

        if (user.notification_settings !== null) {
            vm.personMoved = user.notification_settings.person_moved;
            vm.personAssigned = user.notification_settings.person_assigned;
            vm.weeklyDigest = user.notification_settings.weekly_digest;
        }

        vm.legacyNavigation = !user.beta_mode;
        if (user.beta_mode === null) {
            vm.legacyNavigation = $rootScope.legacyNavigation;
        }
    }

    function reload() {
        nativeLocation.reload();
    }

    function updatePreferences() {
        vm.user.notification_settings = {
            person_moved: vm.personMoved,
            person_assigned: vm.personAssigned,
            weekly_digest: vm.weeklyDigest,
        };

        if (vm.selectedLanguage) {
            vm.selectedLanguageChanged =
                vm.user.language !== vm.selectedLanguage.abbreviation;
            vm.user.language = vm.selectedLanguage.abbreviation;
        }

        vm.user.beta_mode = !vm.legacyNavigation;

        return preferencesPageService
            .updatePreferences(vm.user.serialize())
            .then(function() {
                $rootScope.legacyNavigation = !vm.user.beta_mode;
            });
    }
}
