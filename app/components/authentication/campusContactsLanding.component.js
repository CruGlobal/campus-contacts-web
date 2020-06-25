import campusContactsLogo from '../../assets/images/favicon.svg';

import template from './campusContactsLanding.html';

angular.module('missionhubApp').component('campusContactsLanding', {
    controller: campusContactsLandingController,
    template: template,
});

function campusContactsLandingController() {
    this.campusContactsLogo = campusContactsLogo;
}
