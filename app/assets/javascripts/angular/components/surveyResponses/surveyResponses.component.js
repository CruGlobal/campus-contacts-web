import './surveyResponses.scss';
import chevronLeftIcon from '../../../../images/icons/chevronLeft.svg';

import template from './surveyResponses.html';

angular.module('missionhubApp').component('surveyResponses', {
    controller: surveyResponsesController,
    bindings: {
        survey: '<',
    },
    template: template,
});
function surveyResponsesController($state, httpProxy, $uibModal) {
    this.chevronLeftIcon = chevronLeftIcon;
    this.orgId = $state.params.orgId;

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
            kind: question.kind,
            style: question.style,
        }));
    };

    this.addSurveyResponse = () => {
        $uibModal.open({
            component: 'addSurveyResponseModal',
            resolve: {
                survey: () => this.survey,
            },
            windowClass: 'pivot_theme',
            backdrop: 'static',
            keyboard: false,
        });
    };
}
