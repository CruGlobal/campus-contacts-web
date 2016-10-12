(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewContactsService', organizationOverviewContactsService);

    function organizationOverviewContactsService (httpProxy, apiEndPoint) {
        return {
            // Load an organization's contacts
            loadOrgContacts: function (org, page) {
                return httpProxy.get(apiEndPoint.people.index, {
                    include: [
                        'phone_numbers',
                        'email_addresses',
                        'organizational_permissions',
                        'reverse_contact_assignments.assigned_to'
                    ].join(','),
                    organization_id: org.id,
                    'page[limit]': page.limit,
                    'page[offset]': page.offset
                });
            }
        };
    }

})();
