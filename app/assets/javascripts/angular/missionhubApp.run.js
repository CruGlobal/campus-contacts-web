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
        loggedInPerson,
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

        loggedInPerson.load().then(user => {
            analyticsService.init(
                user.thekey_uid,
                user.fb_uid,
                user.global_registry_mdm_id,
            );
        });

        $transitions.onBefore({}, transition => {
            if (transition.to().data && transition.to().data.isPublic)
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

        $transitions.onFinish({}, transition => {
            analyticsService.track(transition);
        });
    });
