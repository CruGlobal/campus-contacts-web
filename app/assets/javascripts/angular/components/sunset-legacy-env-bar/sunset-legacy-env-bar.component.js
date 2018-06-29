import template from './sunset-legacy-env-bar.html';
import './sunset-legacy-env-bar.scss';

class sunsetLegacyEnvBarController {
    constructor($window) {
        this.$window = $window;
        this.netlifyDomain = localStorage.getItem('netlifyDomain');
    }

    leaveEnvironment() {
        localStorage.removeItem('netlifyDomain');
        this.$window.location.reload();
    }
}

angular.module('missionhubApp').component('sunsetLegacyEnvBar', {
    controller: sunsetLegacyEnvBarController,
    template: template,
});
