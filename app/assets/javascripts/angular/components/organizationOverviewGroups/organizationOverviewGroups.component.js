(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewGroups', {
            require: {
                organizationOverview: '^organizationOverview'
            },
            bindings: {
                org: '<'
            },
            templateUrl: '/assets/angular/components/organizationOverviewGroups/organizationOverviewGroups.html'
        });
})();
