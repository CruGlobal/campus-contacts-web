import template from './addSurveyResponseModal.html';

import './addSurveyResponseModal.scss';

angular.module('missionhubApp').component('addSurveyResponseModal', {
    bindings: {
        resolve: '<',
        dismiss: '&',
        close: '&',
    },
    template: template,
});
