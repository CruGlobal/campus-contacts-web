import template from './surveyResponses.html';

angular.module('missionhubApp').component('surveyResponses', {
    controller: surveyResponsesController,
    template: template,
});
function surveyResponsesController(surveyResponsesService, $state, httpProxy) {
    this.surveyId = $state.params.surveyId;
    this.loaderService = surveyResponsesService;

    this.$onInit = async () => {
        this.questions = await loadQuestions();
    };

    const loadQuestions = async () => {
        const { data } = await httpProxy.get(
            `/surveys/${this.surveyId}/questions`,
            {},
            { errorMessage: 'error.messages.surveyResponses.loadQuestions' },
        );
        return data.sort((a, b) => a.position - b.position).map(question => ({
            id: question.id,
            label: question.column_title || question.label,
        }));
    };
}
