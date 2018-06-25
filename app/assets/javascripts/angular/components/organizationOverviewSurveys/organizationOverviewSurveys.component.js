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


function organizationOverviewSurveysController($uibModal) {
    var vm = this;
    vm.createSurvey = createSurvey;

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
}
