(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewSurveys', {
            require: {
                organizationOverview: '^'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('organizationOverviewSurveys');
            }
        });
})();
