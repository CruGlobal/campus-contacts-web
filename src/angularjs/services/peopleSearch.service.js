peopleSearchService.$inject = ['httpProxy', 'modelsService'];
angular
  .module('missionhubApp')
  .factory('peopleSearchService', peopleSearchService);

function peopleSearchService(httpProxy, modelsService) {
  return {
    search: function(searchQuery) {
      return httpProxy
        .get(
          modelsService.getModelMetadata('person').url.search,
          {
            q: searchQuery,
            include: 'organizational_permissions.organization',
            'fields[organization]': 'name',
          },
          {
            errorMessage: 'error.messages.person.search',
          },
        )
        .then(httpProxy.extractModel);
    },
  };
}
