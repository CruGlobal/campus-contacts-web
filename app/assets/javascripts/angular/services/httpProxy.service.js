/**
 * Created by eijeh on 8/31/16.
 */
(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('httpProxy', proxyService);


    function proxyService ($http, $log, envService, JsonApiDataStore) {
        var proxy = {

            callHttp: function (method, url, params, data) {
                var config = {
                    method: method,
                    url: envService.read('apiUrl') + url,
                    data: data,
                    params: params
                };

                return $http(config).then(function (res) {
                    var response = res.data;
                    JsonApiDataStore.store.sync(response);
                    return response;
                }).catch(function (error) {
                    //We can redirect to some error page if that's better
                    $log.error(error + " - Something has gone terribly wrong.");
                    throw error;
                });
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
