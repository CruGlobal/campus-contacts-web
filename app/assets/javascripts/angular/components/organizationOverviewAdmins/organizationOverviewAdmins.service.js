(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewAdminsService', organizationOverviewAdminsService);

    function organizationOverviewAdminsService (httpProxy, apiEndPoint) {
        return {
            // Load an organization's admins
            loadOrgAdmins: function (org, page) {
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
