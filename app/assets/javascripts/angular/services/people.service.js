/**
 * Created by eijeh on 9/6/16.
 */


(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('peopleService', peopleService);


    peopleService.$inject = ['httpProxy', 'apiEndPoint'];

    function peopleService (httpProxy, apiEndPoint) {

        return {
            saveInteraction: function (model) {
                return httpProxy.post (apiEndPoint.interactions.post, null, model);
            }
        };
    }

})();
