/**
 * Created by eijeh on 9/6/16.
 */


(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('peopleService', peopleService);


    function peopleService (httpProxy, modelsService) {

        return {
            saveInteraction: function (model) {
                return httpProxy.post(modelsService.getModelMetadata('interaction').url.root, null, model);
            }
        };
    }

})();
