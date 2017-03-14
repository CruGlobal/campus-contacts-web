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

        var organizationOverviewPeopleService = {
            buildGetParams: function (orgId, filtersParam) {
                var filters = filtersParam || {};
                var base = {
                    include: [
                        'phone_numbers',
                        'email_addresses',
                        'organizational_permissions',
                        'reverse_contact_assignments'
                    ].join(','),
                    'filters[organization_ids]': orgId
                };
                if (filters.searchString) {
                    base['filters[name]'] = filters.searchString;
                }
                if (filters.labels) {
                    base['filters[label_ids]'] = filters.labels.join(',');
                }
                if (filters.assignedTos) {
                    base['filters[assigned_tos]'] = filters.assignedTos.join(',');
                }
                if (filters.groups) {
                    base['filters[group_ids]'] = filters.groups.join(',');
                }
                return base;
            },

            // Load an organization's people
            loadMoreOrgPeople: function (orgId, filters, listLoader) {
                var requestParams = organizationOverviewPeopleService.buildGetParams(orgId, filters);

                return listLoader
                    .loadMore(requestParams)
                    .then(function (resp) {
                        if (resp.nextBatch.length > 0) {
                            loadAssignments(resp.nextBatch, orgId);
                        }
                        return resp;
                    });
            },

            loadOrgPeopleCount: function (orgId) {
                var requestParams = organizationOverviewPeopleService.buildGetParams(orgId);
                requestParams['page[limit]'] = 0;

                return httpProxy
                    .get(modelsService.getModelMetadata('person').url.all, requestParams)
                    .then(function (resp) {
                        return resp.meta.total;
                    });
            }
        };
        return organizationOverviewPeopleService;
    }
})();
