(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationService', organizationService);

    function organizationService ($q, httpProxy, modelsService, JsonApiDataStore, _) {
        // Keep track of the orgs that the user does not have access to
        var inaccessibleOrgs = [];

        var organizationService = {
            // Load a list of organizations
            loadOrgs: function (orgIds, errorMessage) {
                if (orgIds.length === 0) {
                    return $q.resolve([]);
                }

                return httpProxy.get(modelsService.getModelMetadata('organization').url.all, {
                    'filters[ids]': orgIds.join(',')
                }, {
                    errorMessage: errorMessage
                }).then(httpProxy.extractModels);
            },

            // Lookup and return the org with the specified id if it is loaded
            lookupOrg: function (orgId) {
                return JsonApiDataStore.store.find('organization', orgId);
            },

            // Generate an array of the organization's ancestors as org ids (including the organization itself)
            getOrgHierarchyIds: function (org) {
                if (!org) {
                    return [];
                }
                return (org.ancestry ? org.ancestry.split('/') : []).concat(org.id);
            },

            // Return a promise that resolves to an array of the organization's ancestors (including the organization
            // itself)
            getOrgHierarchy: function (org) {
                var hierarchyIds = _.difference(organizationService.getOrgHierarchyIds(org), inaccessibleOrgs);
                var unloadedOrgIds = hierarchyIds.filter(function (orgId) {
                    return !httpProxy.isLoaded(organizationService.lookupOrg(orgId));
                });

                return organizationService.loadOrgs(unloadedOrgIds, 'error.messages.organization.load_ancestry')
                    .then(function (loadedOrgs) {
                        // Mark as inaccessible orgs that we attempted to load but were not included in the response
                        var newInaccessibleOrgs = _.difference(unloadedOrgIds, _.map(loadedOrgs, 'id'));
                        inaccessibleOrgs = inaccessibleOrgs.concat(inaccessibleOrgs, newInaccessibleOrgs);

                        // Filter out organizations that were not loaded because the user does not have access to them
                        return hierarchyIds.map(organizationService.lookupOrg).filter(_.identity);
                    });
            }
        };

        return organizationService;
    }
})();
