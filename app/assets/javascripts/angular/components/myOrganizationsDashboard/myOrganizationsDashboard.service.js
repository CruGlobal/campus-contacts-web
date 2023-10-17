angular.module('campusContactsApp').factory('myOrganizationsDashboardService', myOrganizationsDashboardService);

function myOrganizationsDashboardService(httpProxy, modelsService, _) {
  return {
    // Return an array of all loaded root organizations
    getRootOrganizations: function () {
      return httpProxy
        .get(
          modelsService.getModelMetadata('organization').url.all,
          {
            'filters[user_created]': false,
            'filters[descendants]': false,
            include: 'organizational_permissions',
            'page[limit]': 100,
          },
          {
            errorMessage: 'error.messages.organization.loadAll',
          },
        )
        .then(httpProxy.extractModels);
    },
  };
}
