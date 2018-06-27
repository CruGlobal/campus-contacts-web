import template from './organizationOverviewSurveys.html';
import './organizationOverviewSurveys.scss';
import _ from 'lodash';

angular.module('missionhubApp').component('organizationOverviewSurveys', {
    require: {
        organizationOverview: '^',
    },
    template: template,
    controller: organizationOverviewSurveysController,
});


function organizationOverviewSurveysController($uibModal, surveyService, confirmModalService) {
    var vm = this;
    vm.createSurvey = createSurvey;
    vm.changeStatus = changeStatus;
    vm.deleteSurvey = deleteSurvey;

    function createSurvey() {
        $uibModal.open({
            component: 'createSurvey',
            resolve: {
                organizationId: _.constant(vm.organizationOverview.org.id),
            },
            windowClass: 'pivot_theme',
            size: 'sm',
        }).result.then((newSurvey) => {
            vm.organizationOverview.surveys.push(newSurvey);
        });
    }

    function changeStatus(survey, active) {
        survey.is_frozen = !active;
        surveyService.updateSurvey(survey);
    }

    function deleteSurvey(survey) {
        if(!survey){ return; }

        confirmModalService
            .create(
                'Are you sure you want to delete ' + survey.title + '?'
            )
            .then(function() {
                surveyService.deleteSurvey(survey).then(() => {
                    vm.organizationOverview.surveys.splice(vm.organizationOverview.surveys.indexOf(survey), 1);
                });
            });
    }
}
