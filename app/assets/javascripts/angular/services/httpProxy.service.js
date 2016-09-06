/**
 * Created by eijeh on 8/31/16.
 */
(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('httpProxy', proxyService);


    proxyService.$inject = ['$http', '$q', '$timeout', '$log', 'envService'];

    function proxyService ($http, $q, $timeout, $log, envService) {
        var proxy = {

            callHttp: function (method, url, params, data) {
            var task = $q.defer();

            var config = {
                method: method,
                url: envService.read('apiUrl') + url,
                data: data,
                params: params
            };

            $timeout(function () {
                $http(config)
                    .success(function (response) {
                        task.resolve(response);
                    })
                    .error(function (error) {
                        //We can redirect to some error page if that's better
                        $log.error(error + " - Something has gone terribly wrong.");
                        task.reject();
                    });
            }, 2000);

            return task.promise;
        },

            get: function (url, params) {
                return this.callHttp("GET", url, params);
            },

            post: function (url, params, data) {
                return this.callHttp("POST", url, params, data);
            },

            put: function (url, params, data) {
                return this.callHttp("PUT", url, params, data);
            },

            delete: function (url, params) {
                return this.callHttp("DELETE", url, params);
            }
        }


        return proxy;
    }

})();
