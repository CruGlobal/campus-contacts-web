import i18next from 'i18next';
import lscache from 'lscache';

angular
    .module('missionhubApp')
    .run(function(
        $window,
        $rootScope,
        $analytics,
        $timeout,
        $transitions,
        localStorageService,
        authenticationService,
    ) {
        lscache.setBucket('missionhub:');

        $rootScope.isLegacyPage = false;

        if ($rootScope.isLegacyPage) {
            $analytics.pageTrack($window.location.pathname);
        }

        $rootScope.whiteBackground = false;
        $transitions.onSuccess({}, transition => {
            $rootScope.whiteBackground = !!transition.to().whiteBackground;
        });

        localStorageService.allowSessionTransfer();

        if (authenticationService.isTokenValid()) {
            authenticationService.setupAuthenticationState();
        }
    });
