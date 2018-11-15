import template from './publicSurvey.html';

angular.module('missionhubApp').component('publicSurvey', {
    bindings: {
        survey: '<',
        preview: '<',
    },
    template,
});
