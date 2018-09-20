import template from './organizationOverviewSurveyResponses.html';
import modalTemplate from './surveyResponsesModal.html';
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

angular.module('missionhubApp').component('surveyResponseModal', {
    template: modalTemplate,
    bindings: {
        dismiss: '&',
    },
    controller: function($scope, localStorageService) {
        var vm = this;

        $scope.closeModal = function() {
            localStorageService.set('newSurveyResponseModal', true);
            vm.dismiss({ $value: 'cancel' });
        };
    },
});

function organizationOverviewSurveyResponsesController(
    $scope,
    surveyService,
    periodService,
    $uibModal,
    localStorageService,
) {
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
        $uibModal.open({
            component: 'surveyResponseModal',
            size: 'sm',
            windowClass: 'pivot_theme',
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
