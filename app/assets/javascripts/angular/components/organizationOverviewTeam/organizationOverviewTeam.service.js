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
                    organization_id: org.id,
                    'page[limit]': page.limit,
                    'page[offset]': page.offset,
                    'filters[permissions]': 'admin,user'
                });
            }
        };
    }

})();
