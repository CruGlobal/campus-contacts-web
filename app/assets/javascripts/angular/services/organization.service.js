(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationService', organizationService);


    function organizationService (JsonApiDataStore, _) {
        var organizationService = {
            // Generate an array of the organization's ancestors as org ids (including the organization itself)
            getOrgHierarchyIds: function (org) {
                if (!org) {
                    return [];
                }
                return (org.ancestry ? org.ancestry.split('/') : []).concat(org.id);
            },

            // Generate an array of the organization's ancestors as org models (including the organization itself)
            getOrgHierarchy: function (org) {
                return organizationService.getOrgHierarchyIds(org)
                    // Convert org ids to organizations
                    .map(function (orgId) {
                        return JsonApiDataStore.store.find('organization', orgId);
                    })
                    // Filter out organizations that were not loaded because the user does not have access to them
                    .filter(_.identity);
            }
        };

        return organizationService;
    }

})();
