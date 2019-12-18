import i18next from 'i18next';

import { getNamesOfLoadedTranslations } from './user-preferences.service';
import template from './user-preferences.html';
import './user-preferences.scss';

class UserPreferences {
    constructor(loggedInPerson, $scope) {
        this.loggedInPerson = loggedInPerson;
        this.$scope = $scope;
        const { user } = this.loggedInPerson.person;
        this.language = user.language;
        const {
            person_moved = true,
            person_assigned = true,
            weekly_digest = true,
        } = user.notification_settings || {};
        this.personMoved = person_moved;
        this.personAssigned = person_assigned;
        this.weeklyDigest = weekly_digest;
    }

    async $onInit() {
        this.languages = await getNamesOfLoadedTranslations();
        this.$scope.$apply();
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
        });
    }
}

angular.module('missionhubApp').component('userPreferences', {
    controller: UserPreferences,
    template: template,
});
