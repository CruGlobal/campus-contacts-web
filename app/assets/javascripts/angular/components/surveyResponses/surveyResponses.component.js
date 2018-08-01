import template from './surveyResponses.html';

angular.module('missionhubApp').component('surveyResponses', {
    controller: surveyResponsesController,
    template: template,
});
function surveyResponsesController(surveyResponsesService, $state) {
    this.surveyId = $state.params.surveyId;
    this.loaderService = surveyResponsesService;
}
