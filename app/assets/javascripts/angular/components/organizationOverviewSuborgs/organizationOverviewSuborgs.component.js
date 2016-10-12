(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewSuborgs', {
            require: {
                organizationOverview: '^organizationOverview'
            },
            templateUrl: '/assets/angular/components/organizationOverviewSuborgs/organizationOverviewSuborgs.html'
        });
})();
