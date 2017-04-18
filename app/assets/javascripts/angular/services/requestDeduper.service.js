(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('RequestDeduper', requestDeduper);

    function requestDeduper ($q, _) {
        /*
         * This class facilitates network request deduplication, i.e. preventing there from being multiple outstanding
         * requests. An instance of this class can be passed to httpProxy to enable deduplication of all requests that
         * use the same deduplicator instance.
         */
        function RequestDeduper () {
            var nextRequestStart = $q.defer();

            // This request should timeout when the next load request starts (if this request has not already
            // completed) so that only one request is in progress at a time and to avoid race conditions in .then
            // handlers.
            this.request = function (makeRequest) {
                // Keep track of whether or not the request was canceled by a later duplicate
                var canceled = false;

                // Inform the previous request that another request is starting, which will abort it if it has not
                // already completed
                nextRequestStart.resolve();

                // Create a new deferred that will be resolved by the next request
                nextRequestStart = $q.defer();
                nextRequestStart.promise.then(function () {
                    canceled = true;
                });

                return makeRequest({ timeout: nextRequestStart.promise }).catch(function (err) {
                    if (canceled) {
                        // This error was the result of it being a duplicate request, so keep the promise that request()
                        // returns to the caller from ever settling
                        return $q(_.noop);
                    }

                    throw err;
                });
            };
        }

        return RequestDeduper;
    }
})();
