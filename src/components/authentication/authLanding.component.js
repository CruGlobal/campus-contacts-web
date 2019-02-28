import template from './authLanding.html';

angular.module('missionhubApp').component('authLanding', {
    controller: authLandingController,
    template: template,
    bindings: {
        accessToken: '<',
    },
});

function authLandingController() {}
