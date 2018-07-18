import template from './surveyOverview.html';
import './surveyOverview.scss';

angular.module('missionhubApp').component('surveyOverview', {
    controller: surveyOverviewController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewController() {
    const vm = this;

    vm.tabNames = [
        {
            id: 'settings',
            name: 'common:nav.settings',
        },
        {
            id: 'keyword',
            name: 'surveys:keyword.keyword',
        },
        // {
        //     id: 'questions',
        //     name: 'surveys:questions:questions',
        // },
    ];
    vm.activeTab = vm.tabNames[0].id;
}
