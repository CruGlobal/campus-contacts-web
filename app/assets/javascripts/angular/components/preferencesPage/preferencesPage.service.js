(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('preferencesPageService', preferencesPageService);

    function preferencesPageService (httpProxy, apiEndPoint, loggedInPerson) {

        return {

            updatePreferences: function (model) {
                return httpProxy.put(apiEndPoint.users.me, null, model);
            },

            readPreferences: function () {

                return loggedInPerson.load().then(function (user) {
                    return user;
                })
            }
        };
    }

})();
