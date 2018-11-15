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
        surveyService
            .getReusableQuestions(
                this.resolve.orgId,
                this.resolve.currentQuestions,
            )
            .then(({ predefined, previouslyUsed }) => {
                this.predefinedQuestions = predefined;
                this.previouslyUsedQuestions = previouslyUsed;
            });
    };

    this.addQuestion = question => {
        this.resolve.addQuestion(question);

        //remove question from list
        if (question.predefined) {
            this.predefinedQuestions.splice(
                this.predefinedQuestions.indexOf(question),
                1,
            );
        } else {
            this.previouslyUsedQuestions.splice(
                this.previouslyUsedQuestions.indexOf(question),
                1,
            );
        }
    };
}
