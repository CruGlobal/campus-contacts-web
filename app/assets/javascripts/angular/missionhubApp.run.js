import lscache from 'lscache';

angular
    .module('missionhubApp')
    .run(function(
        $window,
        $rootScope,
        $analytics,
        $transitions,
        localStorageService,
        authenticationService,
        loggedInPerson,
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

        $transitions.onBefore({}, transition => {
            if (
                !authenticationService.doesRouteRequireAuthentication(
                    transition.to().name,
                )
            )
                return true;

            if (!authenticationService.isTokenValid()) {
                authenticationService.removeAccess();
                return transition.router.stateService.target('signIn');
            }

            return loggedInPerson.load().catch(e => {
                if (e.status === 401) {
                    authenticationService.removeAccess();
                    return transition.router.stateService.target('signIn');
                }
            });
        });
    });
