import template from './surveyTypeformModal.html';

angular.module('missionhubApp').component('surveyTypeformModal', {
    controller: surveyTypeformModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
    },
});

function surveyTypeformModalController() {}
