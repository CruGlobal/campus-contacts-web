(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationBreadcrumbsService', organizationBreadcrumbsService);


    function organizationBreadcrumbsService (JsonApiDataStore, _) {
        return {
            // Generate an array of the organization's ancestors (including the organization itself)
            getOrgHierarchy: function (orgId) {
                var org = JsonApiDataStore.store.find('organization', orgId);
                return (org ? org.ancestry.split('/').concat(org.id) : [])
                    // Convert org ids to organizations
                    .map(function (orgId) {
                        return JsonApiDataStore.store.find('organization', orgId);
                    })
                    // Filter out organizations that were not loaded because the user does not have access to them
                    .filter(_.identity);
            }
        };
    }

})();
