(function () {
    'use strict';

    /*
     * Decorate $templateRequest so that failures can be retried.
     */
    angular
        .module('missionhubApp')
        .decorator('$templateRequest', $templateRequest);

    function $templateRequest ($delegate, errorService, tFilter, _) {
        var retryConfig = _.defaults({
            // Retry all errors
            retryFilter: _.constant(true)
        }, errorService.networkRetryConfig);

        // Wrap $templateRequest in the autoRetry decorator so that failed template loads can be retried
        var decorated = errorService.autoRetry(function () {
            return $delegate.apply(null, arguments).catch(function (err) {
                // Add a user-friendly error message to the original error
                err.message = tFilter('error.messages.template_request.load_template');
                throw err;
            });
        }, retryConfig);

        // Delegate get and sets on the totalPendingRequests property to the original $templateRequest function
        Object.defineProperty(decorated, 'totalPendingRequests', {
            configurable: true,
            enumerable: true,
            get: function () {
                return $delegate.totalPendingRequests;
            },
            set: function (value) {
                $delegate.totalPendingRequests = value;
            }
        });

        return decorated;
    }
})();
