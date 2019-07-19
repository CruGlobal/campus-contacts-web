import './organizationOverviewSurveyResponses.scss';
import _ from 'lodash';

import template from './organizationOverviewSurveyResponses.html';

angular
    .module('missionhubApp')
    .component('organizationOverviewSurveyResponses', {
        require: {
            organizationOverview: '^',
        },
        template: template,
        controller: organizationOverviewSurveyResponsesController,
    });

function organizationOverviewSurveyResponsesController(
    $scope,
    surveyService,
    periodService,
) {
    this.surveyStats = {};
    this.$onInit = () => {
        //get survey stats
        this.getSurveyStats();

        //on period change, update survey stats
        periodService.subscribe($scope, () => {
            this.surveyStats = {};
            this.getSurveyStats();
        });
    };

    this.getSurveyStats = () => {
        _.forEach(this.organizationOverview.surveys, survey => {
            surveyService.getStats(survey.id).then(statData => {
                this.surveyStats[survey.id] = statData;
            });
        });
    };
}
