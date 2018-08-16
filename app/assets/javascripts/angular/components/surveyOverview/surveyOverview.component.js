import template from './surveyOverview.html';
import './surveyOverview.scss';
import chevronLeftIcon from '../../../../images/icons/chevronLeft.svg';

angular.module('missionhubApp').component('surveyOverview', {
    controller: surveyOverviewController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewController() {
    this.chevronLeftIcon = chevronLeftIcon;
    this.tabNames = [
        {
            id: 'settings',
            name: 'surveys:settings.settings',
        },
        {
            id: 'keyword',
            name: 'surveys:keyword.keyword',
        },
        {
            id: 'questions',
            name: 'surveys:questions:questions',
        },
    ];
    this.activeTab = this.tabNames[0].id;
}
