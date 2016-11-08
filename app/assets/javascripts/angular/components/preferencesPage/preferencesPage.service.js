(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('preferencesPageService', preferencesPageService);

    function preferencesPageService (httpProxy, modelsService, loggedInPerson) {

        return {

            updatePreferences: function (model) {
                return httpProxy.put(modelsService.getModelMetadata('user').url.single('me'), null, model);
            },

            readPreferences: function () {
                return loggedInPerson.load();
            }
        };
    }

})();
