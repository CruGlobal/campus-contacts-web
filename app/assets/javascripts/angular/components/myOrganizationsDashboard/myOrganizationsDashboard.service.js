angular
    .module('missionhubApp')
    .factory(
        'myOrganizationsDashboardService',
        myOrganizationsDashboardService,
    );

function myOrganizationsDashboardService(
    JsonApiDataStore,
    loggedInPerson,
    permissionService,
    httpProxy,
    modelsService,
    _,
) {
    return {
        // Return an array of all loaded root organizations
        getRootOrganizations: function() {
            return httpProxy
                .get(
                    modelsService.getModelMetadata('organization').url.all,
                    {
                        'filters[user_created]': false,
                        include: 'organizational_permissions',
                    },
                    {
                        errorMessage: 'error.messages.organization.loadAll',
                    },
                )
                .then(httpProxy.extractModels);
        },
    };
}
