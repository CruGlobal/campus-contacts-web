import template from './surveyResponses.html';

angular.module('missionhubApp').component('surveyResponses', {
    controller: surveyResponsesController,
    bindings: {
        survey: '<',
    },
    template: template,
});
function surveyResponsesController(surveyResponsesService, $state, httpProxy) {
    this.orgId = $state.params.orgId;
    this.loaderService = {
        ...surveyResponsesService,
        listLoader: surveyResponsesService.createListLoader(),
    };

    this.$onInit = async () => {
        this.questions = await loadQuestions();
    };

    const loadQuestions = async () => {
        const { data } = await httpProxy.get(
            `/surveys/${this.survey.id}/questions`,
            {},
            { errorMessage: 'error.messages.surveyResponses.loadQuestions' },
        );
        return data.sort((a, b) => a.position - b.position).map(question => ({
            id: question.id,
            label: question.column_title || question.label,
        }));
    };
}
