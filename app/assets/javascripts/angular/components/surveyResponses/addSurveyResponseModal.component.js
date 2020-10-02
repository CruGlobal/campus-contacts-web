import template from './addSurveyResponseModal.html';

import './addSurveyResponseModal.scss';

angular.module('campusContactsApp').component('addSurveyResponseModal', {
    bindings: {
        resolve: '<',
        dismiss: '&',
        close: '&',
    },
    template: template,
});
