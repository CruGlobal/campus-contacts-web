(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .run(function ($http, $templateCache, assetPathFilter) {
            // Preload the error message template so that it will be available in the case of a network error when it
            // is most likely to be needed
            $http.get(assetPathFilter('angular/templates/retryToastTemplate.html'), { cache: $templateCache });
        })
        .run(function ($window, $rootScope, $analytics, lscache, spaPage, _) {
            lscache.setBucket('missionhub:');

            // Determine whether this page is a SPA page or a legacy page
            $rootScope.isSpaPage = spaPage;
            $rootScope.isLegacyPage = !$rootScope.isSpaPage;

            if ($rootScope.isLegacyPage) {
                $analytics.pageTrack($window.location.pathname);
            }

            /* eslint-disable lines-around-comment */
            $window.location.search.slice(1)
                // Break up querystring into its individual parameters
                .split('&')
                // Look for beta=0 or beta=1
                .map(function (part) {
                    return /^beta=(0|1)$/.exec(part);
                })
                // Filter out null non-matches
                .filter(_.identity)
                // Update beta mode
                .forEach(function (matches) {
                    var betaMode = matches[1];
                    if (betaMode === '0') {
                        // Disable beta mode
                        $window.localStorage.removeItem('beta');
                    } else if (betaMode === '1') {
                        // Enable beta mode
                        $window.localStorage.setItem('beta', true);
                    }
                });
            /* eslint-enable lines-around-comment */

            $rootScope.betaMode = $window.localStorage.getItem('beta') !== null;
        });
})();
