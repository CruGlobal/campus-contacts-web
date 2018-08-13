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
    this.tabNames = [
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
    this.activeTab = this.tabNames[0].id;
}
