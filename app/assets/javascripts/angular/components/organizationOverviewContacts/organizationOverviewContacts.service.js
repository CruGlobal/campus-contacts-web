(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewContactsService', organizationOverviewContactsService);

    function organizationOverviewContactsService (httpProxy, apiEndPoint) {
        return {
            // Load an organization's contacts
            loadOrgContacts: function (orgId, page) {
                return httpProxy.get(apiEndPoint.people.index, {
                    include: [
                        'phone_numbers',
                        'email_addresses',
                        'organizational_permissions',
                        'reverse_contact_assignments.assigned_to'
                    ].join(','),
                    'page[limit]': page.limit,
                    'page[offset]': page.offset,
                    'filters[organization_ids]': orgId
                })
            }
        };
    }

})();
