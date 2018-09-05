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
            listLoader,
            loaderService,
            surveyId,
        ) {
            const requestParams = peopleScreenService.buildListParams(
                orgId,
                filters,
                order,
                surveyId,
            );

            return listLoader
                .loadMore(
                    requestParams,
                    surveyId ? peopleScreenService.transformData : undefined,
                )
                .then(function(resp) {
                    // Load the assignments in parallel
                    peopleScreenService.loadAssignedTos(resp.nextBatch, orgId);
                    return resp;
                });
        },

        loadOrgPeopleCount: function(orgId) {
            const requestParams = peopleScreenService.buildListParams(orgId);
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

        buildListParams: (
            orgId,
            filters = {},
            orderParam = [],
            surveyId = '',
        ) => ({
            include: [
                'phone_numbers',
                'email_addresses',
                'organizational_permissions',
                'reverse_contact_assignments',
                ...(surveyId ? ['answer_sheets.answers'] : []),
            ].join(','),
            sort: peopleScreenService.buildOrderString(orderParam),
            'filters[organization_ids]': orgId,
            ...(surveyId
                ? {
                      'filters[answer_sheets][survey_ids]': surveyId,
                  }
                : {}),
            ...(filters.searchString
                ? {
                      'filters[name]': filters.searchString,
                  }
                : {}),
            ...(filters.includeArchived
                ? {
                      'filters[include_archived]': true,
                  }
                : {}),
            ...(filters.labels
                ? {
                      'filters[label_ids]': filters.labels.join(','),
                  }
                : {}),
            ...(filters.assignedTos
                ? {
                      'filters[assigned_tos]': filters.assignedTos.join(','),
                  }
                : {}),
            ...(filters.groups
                ? {
                      'filters[group_ids]': filters.groups.join(','),
                  }
                : {}),
            ...(filters.statuses
                ? {
                      'filters[statuses]': filters.statuses.join(','),
                  }
                : {}),
            ...(filters.genders
                ? {
                      'filters[genders]': filters.genders.join(','),
                  }
                : {}),
            ...(filters.questions
                ? Object.entries(filters.questions).reduce(
                      (acc, [questionId, values]) => ({
                          ...acc,
                          [`filters[answer_sheets][answers][${questionId}][]`]: values,
                      }),
                      {},
                  )
                : {}),
            ...(filters.answerMatchingOptions
                ? Object.entries(filters.answerMatchingOptions).reduce(
                      (acc, [questionId, value]) => ({
                          ...acc,
                          [`filters[answer_sheets][answers_options][${questionId}]`]: value,
                      }),
                      {},
                  )
                : {}),
            'fields[person]':
                'first_name,last_name,gender,email_addresses,phone_numbers,answer_sheets,organizational_permissions,reverse_contact_assignments',
            'fields[organizational_permission]':
                'followup_status,organization_id,permission_id',
            'fields[email_address]': 'email,primary',
            'fields[phone_number]': 'number,primary',
            'fields[contact_assignment]': 'assigned_to,organization,created_at',
            'fields[organization]': 'id',
            'fields[answer_sheet]': 'answers,survey',
            'fields[answer]': 'value,question',
            'fields[question]': 'id',
            'fields[survey]': 'id',
        }),

        // Convert an array of field order entries in the format { field, direction: 'asc'|'desc' into the order
        // string expected by he API
        buildOrderString: function(order) {
            return order
                .map(function(orderEntry) {
                    return `${
                        orderEntry.direction === 'desc' ? '-' : ''
                    }${orderEntry.field}`;
                })
                .join(',');
        },

        transformData: params => data => {
            // We MUST mutate this object here to keep Angular watchers watching the JsonApiDataStore for changes which is stupid. Everything should work with immutable data but it wasn't implemented that way... An example where creating a new object broke something is updating a contact assignment on the peopleScreen.
            return Object.assign(data, {
                answers: (
                    _.findLast(
                        data.answer_sheets,
                        sheet =>
                            sheet.survey.id ===
                            params['filters[answer_sheets][survey_ids]'],
                    ) || { answers: [] }
                ).answers.reduce(
                    (acc, answer) => ({
                        ...acc,
                        [answer.question.id]: [
                            ...(acc[answer.question.id] || []),
                            answer.value,
                        ],
                    }),
                    {},
                ),
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
        exportPeople: function(selection, order) {
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
                sort: peopleScreenService.buildOrderString(order),
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
