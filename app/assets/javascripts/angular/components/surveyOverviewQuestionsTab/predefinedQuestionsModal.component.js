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
            this.predefinedQuestions = questions.filter(
                question =>
                    !this.resolve.currentQuestions.includes(question.id),
            );
        });
    };

    this.addQuestion = question => {
        this.resolve.addQuestion(question);

        //remove question from list
        this.predefinedQuestions.splice(
            this.predefinedQuestions.indexOf(question),
            1,
        );
    };
}
