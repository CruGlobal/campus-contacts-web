angular
    .module('missionhubApp')
    .factory(
        'organizationOverviewSuborgsService',
        organizationOverviewSuborgsService,
    );

function organizationOverviewSuborgsService(httpProxy, modelsService) {
    var organizationOverviewSuborgsService = {
        buildGetParams: function(orgId) {
            return {
                include: ['groups', 'surveys'].join(','),
                'filters[parent_ids]': orgId,
                'filters[user_created]': false,
            };
        },

        // Load an organization's sub-orgs
        // The "org" parameter may either be an organization model or an organization id
        loadOrgSubOrgs: function(org, listLoader) {
            var requestParams = organizationOverviewSuborgsService.buildGetParams(
                org.id || org,
            );
            if (listLoader) {
                return listLoader.loadMore(requestParams);
            }

            return httpProxy
                .get(
                    modelsService.getModelMetadata('organization').url.all,
                    requestParams,
                )
                .then(resp => {
                    return resp.data;
                });
        },

        loadOrgSubOrgCount: function(orgId) {
            var requestParams = organizationOverviewSuborgsService.buildGetParams(
                orgId,
            );
            requestParams['page[limit]'] = 0;
            return httpProxy
                .get(
                    modelsService.getModelMetadata('organization').url.all,
                    requestParams,
                    {
                        errorMessage:
                            'error.messages.organization_overview_suborgs.load_org_suborg_count',
                    },
                )
                .then(function(resp) {
                    return resp.meta.total;
                });
        },
    };
    return organizationOverviewSuborgsService;
}
