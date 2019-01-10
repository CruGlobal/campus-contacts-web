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
        facebookService,
        analyticsService,
    ) {
        lscache.setBucket('missionhub:');

        $rootScope.whiteBackground = false;
        $transitions.onSuccess({}, transition => {
            $rootScope.whiteBackground = !!transition.to().whiteBackground;
        });

        $window.fbAsyncInit = function() {
            facebookService.init();
        };

        localStorageService.allowSessionTransfer();

        if (authenticationService.isTokenValid()) {
            authenticationService.setupAuthenticationState();
        }

        facebookService.loadSDK()(document);

        //Hack, we do not want the analytics to run when testing
        if (!$window.__karma__) analyticsService.init();

        $transitions.onBefore({}, transition => {
            if (transition.to().data && transition.to().data.isPublic)
                return true;

            if (!authenticationService.isTokenValid()) {
                authenticationService.removeAccess();
                return transition.router.stateService.target('signIn');
            }
        });

        $transitions.onFinish({}, transition => {
            if (!$window.__karma__) analyticsService.track(transition);
        });
    });
