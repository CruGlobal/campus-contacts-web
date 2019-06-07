import template from './appReact.html';

angular.module('missionhubApp').component('appReact', {
    controller: AppReactController,
    template: template,
});

function AppReactController($rootScope) {}
