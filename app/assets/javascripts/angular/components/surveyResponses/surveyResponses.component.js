import template from './surveyResponses.html';
import './surveyResponses.scss';

angular.module('missionhubApp').component('surveyResponses', {
    controller: surveyResponsesController,
    bindings: {
        survey: '<',
    },
    template: template,
});
function surveyResponsesController(
    surveyResponsesService,
    $state,
    httpProxy,
    $uibModal,
) {
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
        return data.map(question => ({
            id: question.id,
            label: question.column_title || question.label,
        }));
    };

    this.addSurveyResponse = () => {
        const modal = $uibModal.open({
            component: 'addSurveyResponseModal',
            resolve: {
                survey: () => this.survey,
            },
            windowClass: 'pivot_theme',
            backdrop: 'static',
            keyboard: false,
        });
        modal.result.then(() => {
            //Refresh people screen
        });
    };
}
