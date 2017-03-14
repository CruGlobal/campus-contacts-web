(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewTeamService', organizationOverviewTeamService);

    function organizationOverviewTeamService (httpProxy, modelsService) {
        var organizationOverviewTeamService = {
            buildGetParams: function (orgId) {
                return {
                    include: [
                        'phone_numbers',
                        'email_addresses'
                    ].join(','),
                    'filters[organization_ids]': orgId,
                    'filters[permissions]': 'admin,user'
                };
            },

            // Load an organization's team members
            // The "org" parameter may either be an organization model or an organization id
            loadOrgTeam: function (org, listLoader) {
                var orgId = org.id || org;
                var requestParams = organizationOverviewTeamService.buildGetParams(orgId);
                return listLoader.loadMore(requestParams);
            },

            loadOrgTeamCount: function (orgId) {
                var requestParams = organizationOverviewTeamService.buildGetParams(orgId);
                requestParams['page[limit]'] = 0;

                return httpProxy
                    .get(modelsService.getModelMetadata('person').url.all, requestParams)
                    .then(function (resp) {
                        return resp.meta.total;
                    });
            }
        };
        return organizationOverviewTeamService;
    }
})();
