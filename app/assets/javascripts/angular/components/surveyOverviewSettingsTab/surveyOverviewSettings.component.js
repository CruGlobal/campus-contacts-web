import template from './surveyOverviewSettings.html';
import _ from 'lodash';

angular.module('missionhubApp').component('surveyOverviewSettings', {
    controller: surveyOverviewSettingsController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewSettingsController($scope, surveyService) {
    const vm = this;

    const saveSurvey = _.throttle(
        (newSurveyData, oldSurveyData) => {
            if (angular.equals(newSurveyData, oldSurveyData)) {
                return;
            }

            vm.survey.title = vm.surveyEdit.title;
            vm.survey.welcome_message = vm.surveyEdit.welcome_message;
            vm.survey.post_survey_message = vm.surveyEdit.post_survey_message;

            surveyService.updateSurvey(vm.survey);
        },
        1500,
        { leading: false },
    );

    vm.$onInit = () => {
        vm.surveyEdit = {
            title: vm.survey.title,
            welcome_message: vm.welcome_message,
            post_survey_message: vm.post_survey_message,
        };

        $scope.$watch(
            () => {
                return vm.surveyEdit;
            },
            saveSurvey,
            true,
        );
    };
}
