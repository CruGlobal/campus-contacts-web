(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewTeamService', organizationOverviewTeamService);

    function organizationOverviewTeamService (httpProxy, modelsService) {
        return {
            // Load an organization's team members
            loadOrgTeam: function (org, page) {
                if (org.id) {
                    org = org.id;
                }
                return httpProxy.get(modelsService.getModelMetadata('person').url.all, {
                    include: [
                        'phone_numbers',
                        'email_addresses'
                    ].join(','),
                    'page[limit]': page.limit,
                    'page[offset]': page.offset,
                    'filters[organization_ids]': org,
                    'filters[permissions]': 'admin,user'
                });
            }
        };
    }

})();
