(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewContactsService', organizationOverviewContactsService);

    function organizationOverviewContactsService (httpProxy, modelsService, _) {
        function loadAssignments (people, orgId) {
            var assignedTos = _.chain(people)
                .map('reverse_contact_assignments')
                .flatten()
                .filter(['organization.id', orgId])
                .map('assigned_to')
                .value();
            var unloaded = _.filter(assignedTos, { '_placeHolder': true });
            var unloadedIds = _.chain(unloaded).map('id').uniq().value();

            if(unloadedIds.length === 0) {
                return;
            }
            var getParams = {include: '', 'filters[ids]': unloadedIds.join(',')};
            httpProxy.get(modelsService.getModelMetadata('person').url.all, getParams);
        }

        return {
            // Load an organization's contacts
            loadOrgContacts: function (orgId, page) {
                return httpProxy.get(modelsService.getModelMetadata('person').url.all, {
                    include: [
                        'phone_numbers',
                        'email_addresses',
                        'organizational_permissions',
                        'reverse_contact_assignments'
                    ].join(','),
                    'page[limit]': page.limit,
                    'page[offset]': page.offset,
                    'filters[organization_ids]': orgId
                }).then(function (resp) {
                    if(resp.data.length > 0) {
                        loadAssignments(resp.data, orgId);
                    }
                    return resp;
                });
            }
        };
    }

})();
