import template from './predefinedQuestionsModal.html';

angular.module('missionhubApp').component('predefinedQuestionsModal', {
    controller: predefinedQuestionsModalController,
    template: template,
    bindings: {
        resolve: '<',
        close: '&',
        dismiss: '&',
    },
});

function predefinedQuestionsModalController(surveyService) {
    this.$onInit = () => {
        surveyService.getPredefinedQuestions().then(questions => {
            this.predefinedQuestions = questions;
        });
    };
}
