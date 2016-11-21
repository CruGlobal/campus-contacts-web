(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewTeamService', organizationOverviewTeamService);

    function organizationOverviewTeamService (httpProxy, modelsService) {
        return {
            // Load an organization's team members
            // The "org" parameter may either be an organization model or an organization id
            loadOrgTeam: function (org, page) {
                var orgId = org.id || org;
                return httpProxy.get(modelsService.getModelMetadata('person').url.all, {
                    include: [
                        'phone_numbers',
                        'email_addresses'
                    ].join(','),
                    'page[limit]': page.limit,
                    'page[offset]': page.offset,
                    'filters[organization_ids]': orgId,
                    'filters[permissions]': 'admin,user'
                });
            }
        };
    }
})();
