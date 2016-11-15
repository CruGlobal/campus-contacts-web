(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewContactsService', organizationOverviewContactsService);

    function organizationOverviewContactsService (httpProxy, modelsService) {
        return {
            // Load an organization's contacts
            loadOrgContacts: function (orgId, page) {
                return httpProxy.get(modelsService.getModelMetadata('person').url.all, {
                    include: [
                        'phone_numbers',
                        'email_addresses',
                        'organizational_permissions',
                        'reverse_contact_assignments.assigned_to'
                    ].join(','),
                    'page[limit]': page.limit,
                    'page[offset]': page.offset,
                    'filters[organization_ids]': orgId
                });
            }
        };
    }

})();
