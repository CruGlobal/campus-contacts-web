(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('peopleSearchService', peopleSearchService);

    function peopleSearchService (httpProxy, modelsService) {
        return {
            search: function (searchQuery) {
                return httpProxy.get(
                    modelsService.getModelMetadata('person').url.search,
                    {
                        q: searchQuery
                    },
                    {
                        errorMessage: 'error.messages.person.search'
                    }
                )
                    .then(httpProxy.extractModel);
            }
        };
    }
})();
