(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewPeopleService', organizationOverviewPeopleService);

    function organizationOverviewPeopleService ($q, httpProxy, modelsService, massEditService, _) {
        var organizationOverviewPeopleService = {
            // Load all of the people that a list of people are assigned to
            loadAssignedTos: function (people, orgId) {
                // Find all of the people that any of those people are assigned to
                var assignedTos = _.chain(people)
                    .map('reverse_contact_assignments')
                    .flatten()
                    .filter(['organization.id', orgId])
                    .map('assigned_to')
                    .uniq()
                    .value();

                // Find the ids of those assigned to people who are not loaded
                var unloadedIds = _.chain(assignedTos)
                    .filter(_.negate(httpProxy.isLoaded))
                    .map('id')
                    .value();

                // Load those unloaded models
                return unloadedIds.length === 0 ?
                    $q.resolve() :
                    httpProxy.get(modelsService.getModelMetadata('person').url.all, {
                        include: '',
                        'filters[ids]': unloadedIds.join(',')
                    }, {
                        errorMessage: 'error.messages.organization_overview_people.load_assignments'
                    });
            },

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
                            organizationOverviewPeopleService.loadAssignedTos(resp.nextBatch, orgId);
                        }
                        return resp;
                    });
            },

            loadOrgPeopleCount: function (orgId) {
                var requestParams = organizationOverviewPeopleService.buildGetParams(orgId);
                requestParams['page[limit]'] = 0;

                return httpProxy
                    .get(modelsService.getModelMetadata('person').url.all, requestParams, {
                        errorMessage: 'error.messages.organization_overview_people.load_org_people_count'
                    })
                    .then(function (resp) {
                        return resp.meta.total;
                    });
            },

            // Archive the selected people
            archivePeople: function (selection) {
                return massEditService.applyChanges(selection, { archived: true });
            },

            // Delete the selected people
            deletePeople: function (selection) {
                return massEditService.applyChanges(selection, { delete: true });
            }
        };
        return organizationOverviewPeopleService;
    }
})();
