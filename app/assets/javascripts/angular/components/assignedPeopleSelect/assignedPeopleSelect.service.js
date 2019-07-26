angular
    .module('missionhubApp')
    .factory('assignedPeopleSelectService', assignedPeopleSelectService);

function assignedPeopleSelectService(
    httpProxy,
    modelsService,
    loggedInPerson,
    permissionService,
) {
    return {
        // Search for people in a particular organization that match the query
        searchPeople: function(organizationId, deduper) {
            return httpProxy
                .get(
                    modelsService.getModelMetadata('person').url.search,
                    {
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
        // Determine whether a person is the currently logged-in person
        isMe: function(person) {
            return loggedInPerson.person === person;
        },
    };
}
