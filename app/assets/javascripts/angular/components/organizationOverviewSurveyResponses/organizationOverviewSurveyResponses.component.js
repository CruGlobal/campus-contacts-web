import template from './organizationOverviewSurveyResponses.html';
import './organizationOverviewSurveyResponses.scss';
import _ from 'lodash';

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
    $uibModal,
    localStorageService,
    $log,
) {
    let surveyResponseModalClosed = async modal => {
        try {
            await modal.closed;
            localStorageService.set('newSurveyResponseModal', true);
        } catch (error) {
            $log.log(error);
        }
    };

    this.surveyStats = {};
    this.$onInit = () => {
        if (!localStorageService.get('newSurveyResponseModal')) {
            this.showSurveyModal();
        }

        //get survey stats
        this.getSurveyStats();

        //on period change, update survey stats
        periodService.subscribe($scope, () => {
            this.surveyStats = {};
            this.getSurveyStats();
        });
    };

    this.showSurveyModal = () => {
        const modal = $uibModal.open({
            component: 'surveyResponseModal',
            size: 'sm',
            windowClass: 'pivot_theme',
        });
        surveyResponseModalClosed(modal);
    };

    this.getSurveyStats = () => {
        _.forEach(this.organizationOverview.surveys, survey => {
            surveyService.getStats(survey.id).then(statData => {
                this.surveyStats[survey.id] = statData;
            });
        });
    };
}
