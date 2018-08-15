angular
    .module('missionhubApp')
    .factory('surveyResponsesService', surveyResponsesService);

function surveyResponsesService(ProgressiveListLoader, RequestDeduper) {
    const listLoader = new ProgressiveListLoader({
        modelType: 'answer_sheet',
        requestDeduper: new RequestDeduper(),
        errorMessage:
            'error.messages.organization_overview_people.load_people_chunk',
    });
    const buildListParams = (
        orgId,
        filters = {},
        orderParam = [],
        surveyId = '',
    ) => ({
        include: [
            'person.phone_numbers',
            'person.email_addresses',
            'person.organizational_permissions',
            'person.reverse_contact_assignments',
            'answers',
        ].join(','),
        sort: buildOrderString(orderParam),
        'filters[survey_ids]': surveyId,
        ...(filters.searchString
            ? {
                  'filters[people][name]': filters.searchString,
              }
            : {}),
        ...(filters.includeArchived
            ? {
                  'filters[people][include_archived]': true,
              }
            : {}),
        ...(filters.labels
            ? {
                  'filters[people][label_ids]': filters.labels.join(','),
              }
            : {}),
        ...(filters.assignedTos
            ? {
                  'filters[people][assigned_tos]': filters.assignedTos.join(
                      ',',
                  ),
              }
            : {}),
        ...(filters.groups
            ? {
                  'filters[people][group_ids]': filters.groups.join(','),
              }
            : {}),
        ...(filters.statuses
            ? {
                  'filters[people][statuses]': filters.statuses.join(','),
              }
            : {}),
        ...(filters.genders
            ? {
                  'filters[people][genders]': filters.genders.join(','),
              }
            : {}),
    });
    // Convert an array of field order entries in the format { field, direction: 'asc'|'desc' into the order
    // string expected by he API
    const buildOrderString = function(order) {
        return ''; // TODO: remove once MHP-1789 is fixed and sorting is supported on answer sheets endpoint
        return order
            .map(function(orderEntry) {
                return `people.${
                    orderEntry.direction === 'desc' ? '-' : ''
                }${orderEntry.field}`;
            })
            .join(',');
    };

    const transformData = data => {
        return {
            ...data.person,
            answers: data.answers.reduce(
                (acc, answer) => ({
                    ...acc,
                    [answer.question.id]: [
                        ...(acc[answer.question.id] || []),
                        answer.value,
                    ],
                }),
                {},
            ),
        };
    };

    return {
        listLoader,
        buildListParams,
        buildOrderString,
        transformData,
    };
}
