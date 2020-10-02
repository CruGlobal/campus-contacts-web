import template from './publicSurvey.html';

angular.module('campusContactsApp').component('publicSurvey', {
    bindings: {
        survey: '<',
        preview: '<',
    },
    template,
});
