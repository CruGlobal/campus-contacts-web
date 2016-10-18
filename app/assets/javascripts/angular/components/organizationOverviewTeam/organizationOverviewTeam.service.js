(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewTeamService', organizationOverviewTeamService);

    function organizationOverviewTeamService (httpProxy, apiEndPoint) {
        return {
            // Load an organization's team members
            loadOrgTeam: function (org, page) {
                return httpProxy.get(apiEndPoint.people.index, {
                    include: [
                        'phone_numbers',
                        'email_addresses'
                    ].join(','),
                    'page[limit]': page.limit,
                    'page[offset]': page.offset,
                    'filters[organization_ids]': org.id,
                    'filters[permissions]': 'admin,user'
                });
            }
        };
    }

})();
