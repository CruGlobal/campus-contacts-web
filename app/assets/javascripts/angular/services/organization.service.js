angular
    .module('missionhubApp')
    .factory('organizationService', organizationService);

function organizationService(
    $q,
    httpProxy,
    modelsService,
    JsonApiDataStore,
    _,
) {
    // Keep track of the orgs that the user does not have access to
    let inaccessibleOrgs = new Set();

    const organizationService = {
        // Load a list of organizations
        loadOrgsById: function (orgIds, errorMessage) {
            if (orgIds.length === 0) {
                return $q.resolve([]);
            }

            return httpProxy
                .get(
                    modelsService.getModelMetadata('organization').url.all,
                    {
                        'filters[ids]': orgIds.join(','),
                        'filters[user_created]': false,
                    },
                    {
                        errorMessage: errorMessage,
                    },
                )
                .then(httpProxy.extractModels);
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
            var hierarchyIds = _.difference(
                organizationService.getOrgHierarchyIds(org),
                [...inaccessibleOrgs],
            );
            var unloadedOrgIds = hierarchyIds.filter(function (orgId) {
                return !httpProxy.isLoaded(
                    organizationService.lookupOrg(orgId),
                );
            });

            return organizationService
                .loadOrgsById(
                    unloadedOrgIds,
                    'error.messages.organization.load_ancestry',
                )
                .then(function (loadedOrgs) {
                    // Mark as inaccessible orgs that we attempted to load but were not included in the response
                    const newInaccessibleOrgs = _.difference(
                        unloadedOrgIds,
                        _.map(loadedOrgs, 'id'),
                    );
                    inaccessibleOrgs = new Set([
                        ...inaccessibleOrgs,
                        ...newInaccessibleOrgs,
                    ]);

                    // Filter out organizations that were not loaded because the user does not have access to them
                    return hierarchyIds
                        .map(organizationService.lookupOrg)
                        .filter(_.identity);
                });
        },

        // Search for organizations in the same org tree as the specified org that match the query
        searchOrgs: function (org, query, deduper) {
            var rootOrgId = organizationService.getOrgHierarchyIds(org)[0];
            return httpProxy
                .get(
                    '/organization_search',
                    {
                        q: query,
                        ancestry_roots: rootOrgId,
                        limit: 10,
                    },
                    {
                        deduper: deduper,
                        errorMessage:
                            'error.messages.organization.search_organizations',
                    },
                )
                .then(httpProxy.extractModels);
        },

        createOrg: (org, parentOrg) => {
            return httpProxy
                .post(
                    modelsService.getModelMetadata('organization').url.all,
                    {
                        data: {
                            type: 'organization',
                            attributes: {
                                name: org.name,
                                terminology: org.terminology,
                                show_sub_orgs: org.show_sub_orgs,
                            },
                            relationships: {
                                parent: {
                                    data: {
                                        type: 'organization',
                                        id: parentOrg.id,
                                    },
                                },
                            },
                        },
                    },
                    {
                        errorMessage: 'error.messages.organization.create',
                    },
                )
                .then(httpProxy.extractModels);
        },

        saveOrg: (org) => {
            return httpProxy
                .put(
                    modelsService
                        .getModelMetadata('organization')
                        .url.single(org.id),
                    {
                        data: {
                            type: 'organization',
                            attributes: {
                                name: org.name,
                                terminology: org.terminology,
                                show_sub_orgs: org.show_sub_orgs,
                            },
                        },
                    },
                    {
                        errorMessage: 'error.messages.organization.update',
                    },
                )
                .then(httpProxy.extractModels);
        },

        deleteOrg: (org) => {
            return httpProxy.delete(
                modelsService
                    .getModelMetadata('organization')
                    .url.single(org.id),
                null,
                {
                    errorMessage: 'error.messages.organization.delete',
                    showApiMessage: true,
                },
            );
        },
    };

    return organizationService;
}
