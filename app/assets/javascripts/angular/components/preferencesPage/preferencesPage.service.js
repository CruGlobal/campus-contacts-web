(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('preferencesPageService', preferencesPageService);

    function preferencesPageService (httpProxy, apiEndPoint) {

        return {
            updatePreferences: function (model) {
                return httpProxy.put(apiEndPoint.users.me, null, model);
            },
            readPreferences: function () {
                // something with loggedInPerson
            }
        };
    }

})();
