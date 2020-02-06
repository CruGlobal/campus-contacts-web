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
        searchPeople: function(query, organizationId, deduper) {
            if (!query || query.length < 2) {
                return Promise.resolve([]);
            }

            return httpProxy
                .get(
                    modelsService.getModelMetadata('person').url.all,
                    {
                        'filters[name]': query,
                        'filters[organization_ids]': organizationId,
                        'filters[permission_ids]': permissionService.adminAndUserIds.join(
                            ',',
                        ),
                        'fields[person]': 'first_name,last_name',
                        include: '',
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
