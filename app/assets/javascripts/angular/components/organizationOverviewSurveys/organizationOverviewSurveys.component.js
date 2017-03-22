(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewSurveys', {
            require: {
                organizationOverview: '^'
            },
            templateUrl: '/assets/angular/components/organizationOverviewSurveys/organizationOverviewSurveys.html'
        });
})();
