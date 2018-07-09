import template from './surveyOverview.html';
import './surveyOverview.scss';

angular.module('missionhubApp').component('surveyOverview', {
    controller: surveyOverviewController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewController($scope, p2cOrgId, asyncBindingsService) {
    var vm = this;
    vm.tabNames = ['Settings', 'Keyword', 'Questions'];
    vm.$onInit = asyncBindingsService.lazyLoadedActivate(() => {}, []);
}
