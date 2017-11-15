import template from './organizationOverviewSurveys.html';

angular
    .module('missionhubApp')
    .component('organizationOverviewSurveys', {
        require: {
            organizationOverview: '^'
        },
        template: template
    });
