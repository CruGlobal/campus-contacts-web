import template from './surveyOverview.html';
import './surveyOverview.scss';

angular.module('missionhubApp').component('surveyOverview', {
    controller: surveyOverviewController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewController($scope, asyncBindingsService) {
    var vm = this;
    vm.tabNames = ['Settings', 'Keyword', 'Questions'];
    vm.activeTab = vm.tabNames[0];

    vm.$onInit = asyncBindingsService.lazyLoadedActivate(angular.noop, []);
}
