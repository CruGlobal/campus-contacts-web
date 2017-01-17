(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewPeopleService', organizationOverviewPeopleService);

    function organizationOverviewPeopleService (httpProxy, modelsService, _) {
        function loadAssignments (people, orgId) {
            var assignedTos = _.chain(people)
                .map('reverse_contact_assignments')
                .flatten()
                .filter(['organization.id', orgId])
                .map('assigned_to')
                .value();
            var unloadedIds = _.chain(assignedTos)
                .filter({ _placeHolder: true })
                .map('id')
                .uniq()
                .value();

            if (unloadedIds.length === 0) {
                return;
            }
            httpProxy.get(modelsService.getModelMetadata('person').url.all, {
                include: '',
                'filters[ids]': unloadedIds.join(',')
            });
        }

        function buildGetParams (orgId, page, filters) {
            var base = {
                include: [
                    'phone_numbers',
                    'email_addresses',
                    'organizational_permissions',
                    'reverse_contact_assignments'
                ].join(','),
                'page[limit]': page.limit,
                'page[offset]': page.offset,
                'filters[organization_ids]': orgId
            };
            if (filters.labels) {
                base['filters[label_ids]'] = filters.labels.join(',');
            }
            return base;
        }

        return {
            // Load an organization's people
            loadOrgPeople: function (orgId, page, filters) {
                return httpProxy
                    .get(modelsService.getModelMetadata('person').url.all, buildGetParams(orgId, page, filters || {}))
                    .then(function (resp) {
                        if (resp.data.length > 0) {
                            loadAssignments(resp.data, orgId);
                        }
                        return resp;
                    });
            }
        };
    }
})();
