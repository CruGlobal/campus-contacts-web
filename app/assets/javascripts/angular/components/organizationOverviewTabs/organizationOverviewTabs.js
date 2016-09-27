(function () {
    'use strict';

    var ministryViewTabs = ['suborgs', 'admins', 'groups', 'contacts', 'surveys'];
    angular.module('missionhubApp')
        .constant('ministryViewTabs', ministryViewTabs)
        .constant('ministryViewFirstTab', ministryViewTabs[0]);

    // Create the organization overview tab components
    ministryViewTabs.forEach(function (tab) {
        var componentName = 'organizationOverview' + tab[0].toUpperCase() + tab.slice(1);
        angular.module('missionhubApp').component(componentName, {
            require: {
                organizationOverview: '^organizationOverview'
            },
            bindings: {
                org: '<'
            },
            templateUrl: '/assets/angular/components/organizationOverviewTabs/' + componentName + '.html'
        });
    });
})();
