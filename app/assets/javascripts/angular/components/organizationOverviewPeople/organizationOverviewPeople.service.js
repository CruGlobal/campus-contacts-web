(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewPeopleService', organizationOverviewPeopleService);

    function organizationOverviewPeopleService (httpProxy, modelsService, _) {
        var pageSize = 25;
        var overlapMargin = 1;

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
            buildGetParams: function (orgId, page, filtersParam) {
                var filters = filtersParam || {};
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
            loadMoreOrgPeople: function (orgId, loadedPeople, filters, requestDeduper) {
                // There are two situations where our length gets out of sync from our offset:
                // 1. The already-loaded portion of the data set becomes larger on the server. In this
                // case, we would be requesting the next set after #10, but what we think is #10 is
                // really 11th, so we would see #10 again in the response. This duplication is covered
                // by union-ing the response data with the existing loaded people.
                // 2. The already-loaded portion of the data set becomes smaller on the server. In this
                // case, we would be requesting the next set after #10, but what we think is #10 is
                // now 9th, so we would never load #11 as the server picks up with the 11th item (#12).
                // This off-by-one issue is covered by loading one extra row every 'page' and throwing
                // away duplicates. `overlapMargin` defines how many extra rows to load.
                var page = {
                    limit: pageSize + overlapMargin,
                    offset: Math.max(loadedPeople.length - overlapMargin, 0)
                };
                var getParams = organizationOverviewPeopleService.buildGetParams(orgId, page, filters);

                return httpProxy
                    .get(modelsService.getModelMetadata('person').url.all, getParams, { deduper: requestDeduper })
                    .then(function (resp) {
                        if (resp.data.length > 0) {
                            loadAssignments(resp.data, orgId);
                        }
                        return resp;
                    })
                    .then(function (resp) {
                        var nextBatch = resp.data;
                        var people = _.unionBy(loadedPeople, nextBatch, 'id');
                        var loadedAll = resp.meta.total <= people.length;

                        return {
                            people: people,
                            loadedAll: loadedAll
                        };
                    });
            },

            loadOrgPeopleCount: function (orgId) {
                var getParams = organizationOverviewPeopleService.buildGetParams(orgId, { limit: 0 });

                return httpProxy
                    .get(modelsService.getModelMetadata('person').url.all, getParams)
                    .then(function (resp) {
                        return resp.meta.total;
                    });
            }
        };
        return organizationOverviewPeopleService;
    }
})();
