import './surveyOverview.scss';
import chevronLeftIcon from '../../../../images/icons/chevronLeft.svg';

import template from './surveyOverview.html';

angular.module('missionhubApp').component('surveyOverview', {
    controller: surveyOverviewController,
    bindings: {
        survey: '<',
    },
    template: template,
});

function surveyOverviewController(envService) {
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
    this.surveyLinkPrefix = envService.read('surveyLinkPrefix');
}
