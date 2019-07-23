angular
    .module('missionhubApp')
    .factory('assignedAltSelectService', assignedAltSelectService);

function assignedAltSelectService(
    httpProxy,
    modelsService,
    loggedInPerson,
    permissionService,
) {
    return {
        // Search for people in a particular organization that match the query
        searchPeople: function(query, organizationId, deduper) {
            return httpProxy
                .get(
                    modelsService.getModelMetadata('person').url.search,
                    {
                        q: query,
                        organization_ids: organizationId,
                        'filters[permission_ids]': permissionService.adminAndUserIds.join(
                            ',',
                        ),
                    },
                    {
                        deduper: deduper,
                        errorMessage:
                            'error.messages.assigned_select.search_people',
                        bypassStore: true,
                    },
                )
                .then(httpProxy.extractModels);
        },
        // Get all the labels from the current organizations
        searchLabels: (query, organizationId) => {
            return httpProxy
                .get(
                    `/organizations/${organizationId}`,
                    {
                        include: 'labels',
                    },
                    {
                        errorMessage: 'error.messages.surveys.loadQuestions',
                    },
                )
                .then(data => {
                    return data.data.labels;
                });
        },
        // Determine whether a person is the currently logged-in person
        isMe: function(person) {
            return loggedInPerson.person === person;
        },
    };
}
