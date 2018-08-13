import i18next from 'i18next';

import { getNamesOfLoadedTranslations } from './user-preferences.service';
import template from './user-preferences.html';
import './user-preferences.scss';

class UserPreferences {
    constructor(loggedInPerson, $rootScope) {
        this.loggedInPerson = loggedInPerson;
        this.$rootScope = $rootScope;
        const { user } = this.loggedInPerson.person;
        this.language = user.language;
        this.languages = getNamesOfLoadedTranslations();
        this.personMoved = user.notification_settings.person_moved;
        this.personAssigned = user.notification_settings.person_assigned;
        this.weeklyDigest = user.notification_settings.weekly_digest;
        this.legacyNav = !user.beta_mode;
    }

    onChangeLanguage(language) {
        if (language) {
            i18next.changeLanguage(language);
            this.loggedInPerson.updatePreferences({ language });
        }
    }

    onChangeNotificationSettings() {
        this.loggedInPerson.updatePreferences({
            notification_settings: {
                person_moved: this.personMoved,
                person_assigned: this.personAssigned,
                weekly_digest: this.weeklyDigest,
            },
            beta_mode: !this.legacyNav,
        });
        this.$rootScope.legacyNavigation = this.legacyNav;
    }
}

angular.module('missionhubApp').component('userPreferences', {
    controller: UserPreferences,
    template: template,
});
