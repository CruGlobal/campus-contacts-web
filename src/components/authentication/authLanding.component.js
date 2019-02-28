import template from './authLanding.html';

angular.module('missionhubApp').component('authLanding', {
    template: template,
    bindings: {
        accessToken: '<',
    },
});
