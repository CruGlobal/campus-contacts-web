angular
    .module('missionhubApp')
    .factory('peopleScreenService', peopleScreenService);

function peopleScreenService(
    $http,
    $q,
    $window,
    httpProxy,
    JsonApiDataStore,
    modelsService,
    envService,
    personSelectionService,
    massEditService,
    _,
) {
    const peopleScreenService = {
        // Load all of the people that a list of people are assigned to
        loadAssignedTos: function(people, orgId) {
            // Find all of the people that any of those people are assigned to
            const assignedTos = _.chain(people)
                .map('reverse_contact_assignments')
                .flatten()
                .filter(['organization.id', orgId])
                .map('assigned_to')
                .uniq()
                .value();

            // Find the ids of those assigned to people who are not loaded
            const unloadedIds = _.chain(assignedTos)
                .filter(_.negate(httpProxy.isLoaded))
                .map('id')
                .value();

            // Load those unloaded models
            return unloadedIds.length === 0
                ? $q.resolve()
                : httpProxy.get(
                      modelsService.getModelMetadata('person').url.all,
                      {
                          include: '',
                          'filters[ids]': unloadedIds.join(','),
                      },
                      {
                          errorMessage:
                              'error.messages.organization_overview_people.load_assignments',
                      },
                  );
        },
        // Load an organization's people
        loadMoreOrgPeople: function(
            orgId,
            filters,
            order,
            loaderService,
            surveyId,
        ) {
            const requestParams = loaderService.buildListParams(
                orgId,
                filters,
                order,
                surveyId,
            );

            return loaderService.listLoader
                .loadMore(requestParams, loaderService.transformData)
                .then(function(resp) {
                    // Load the assignments in parallel
                    peopleScreenService.loadAssignedTos(resp.nextBatch, orgId);
                    return resp;
                });
        },

        loadOrgPeopleCount: function(orgId, loaderService) {
            const requestParams = loaderService.buildListParams(orgId);
            requestParams['page[limit]'] = 0;

            return httpProxy
                .get(
                    modelsService.getModelMetadata('person').url.all,
                    requestParams,
                    {
                        errorMessage:
                            'error.messages.organization_overview_people.load_org_people_count',
                    },
                )
                .then(function(resp) {
                    return resp.meta.total;
                });
        },

        // Merge the specified people
        mergePeople: function(personIds, winnerId) {
            const model = new JsonApiDataStore.Model('bulk_people_change');
            model.setAttribute('person_ids', personIds);
            model.setAttribute('winner_id', winnerId);
            return httpProxy.post('/person_merges', model.serialize(), {
                errorMessage:
                    'error.messages.organization_overview_people.merge_people',
            });
        },

        // Export the selected people
        exportPeople: function(selection, order, buildOrderString) {
            const filterParams = _.mapKeys(
                personSelectionService.convertToFilters(selection),
                function(value, key) {
                    return 'filters[' + key + ']';
                },
            );
            const params = _.extend(filterParams, {
                access_token: $http.defaults.headers.common.Authorization.slice(
                    7,
                ), // strip off the "Bearer " part
                organization_id: selection.orgId,
                sort: buildOrderString(order),
                format: 'csv',
            });
            const queryString = _.map(params, function(value, key) {
                return (
                    encodeURIComponent(key) + '=' + encodeURIComponent(value)
                );
            }).join('&');

            // Navigate to the URL to initiate the download
            const url =
                envService.read('apiUrl') +
                modelsService.getModelMetadata('person').url.all +
                '?' +
                queryString;
            $window.location.replace(url);
        },

        // Archive the selected people
        archivePeople: function(selection) {
            return massEditService.applyChanges(selection, { archived: true });
        },

        // Delete the selected people
        deletePeople: function(selection) {
            return massEditService.applyChanges(selection, { delete: true });
        },
    };
    return peopleScreenService;
}
