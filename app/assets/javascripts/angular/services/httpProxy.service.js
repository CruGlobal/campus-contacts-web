/**
 * Created by eijeh on 8/31/16.
 */
(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .service('httpProxy', proxyService);


    proxyService.$inject = ['$http', '$q', '$timeout', '$log', 'envService'];

    function proxyService($http, $q, $timeout, $log, envService) {

        function callHttp(method, url, params, data) {
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
        }

        this.get = function (url, params) {
            return callHttp("GET", url, params);
        };

        this.post = function (url, params, data) {
            return callHttp("POST", url, params, data);
        };

        this.put = function (url, params, data) {
            return callHttp("PUT", url, params, data);
        };

        this.delete = function (url, params) {
            return callHttp("DELETE", url, params);
        };
    }

})();
