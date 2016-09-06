/**
 * Created by eijeh on 9/6/16.
 */


/**
 * Created by eijeh on 9/2/16.
 */


(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .service('organizationalPeopleService', organizationalPeopleService);


    organizationalPeopleService.$inject = ['httpProxy', 'apiEndPoint'];

    function organizationalPeopleService(httpProxy, apiEndPoint) {

        return {

            updatePeople: function (personId, model) {
                return httpProxy.put(apiEndPoint.people.update + personId, model);
            },
            saveAnonymousInteraction: function (model) {
                return httpProxy.post(apiEndPoint.interactions.post, null, model);
            }
        };
    }

})();
