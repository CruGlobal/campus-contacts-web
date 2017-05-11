(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .run(function ($http, $templateCache, assetPathFilter) {
            // Preload the error message template so that it will be available in the case of a network error when it
            // is most likely to be needed
            $http.get(assetPathFilter('angular/templates/retryToastTemplate.html'), { cache: $templateCache });
        })
        .run(function ($window, $rootScope, $analytics, $timeout, lscache, spaPage, _, loggedInPerson) {
            lscache.setBucket('missionhub:');

            // Determine whether this page is a SPA page or a legacy page
            $rootScope.isSpaPage = spaPage;
            $rootScope.isLegacyPage = !$rootScope.isSpaPage;

            if ($rootScope.isLegacyPage) {
                $analytics.pageTrack($window.location.pathname);
            }

            $rootScope.betaMode = $window.localStorage.getItem('beta');
            if ($rootScope.betaMode === null) {
                // This code will run when Angular initializes, but currently we are gaining our
                // authentication from the rails host through a <preload-state> component. This means
                // that the access token isn't populated at the time of application initialization,
                // the $timeout will cause delay this execution until after the first digest.
                $timeout(function () {
                    loggedInPerson.loadOnce().then(function (me) {
                        $rootScope.betaMode = Boolean(me.user.beta_mode);
                    });
                });
            }
        });
})();
