angular
    .module('missionhubApp')
    .run(function (
        $window,
        $rootScope,
        $analytics,
        $transitions,
        localStorageService,
        authenticationService,
        loggedInPerson,
        facebookService,
        analyticsService,
        state,
        $location,
        envService,
    ) {
        $rootScope.whiteBackground = false;
        $transitions.onSuccess({}, (transition) => {
            $rootScope.whiteBackground = !!transition.to().whiteBackground;
        });

        $window.fbAsyncInit = function () {
            facebookService.init();
        };

        if (authenticationService.isTokenValid())
            authenticationService.setupAuthenticationState();

        facebookService.loadSDK()(document);

        analyticsService.init();

        (envService.is('production') ||
            envService.is('productionCampusContacts')) &&
            $location.absUrl().match(/(www\.)?missionhub\.com\/?$/) &&
            !authenticationService.isTokenValid() &&
            ($window.location.href = envService.read('getMissionHub'));

        $transitions.onBefore({}, (transition) => {
            if (transition.to().data && transition.to().data.isPublic)
                return true;

            if ($location.host().includes('mhub.cc')) {
                $window.location.href = envService.read('getMissionHub');
                return false;
            }

            if (!authenticationService.isTokenValid()) {
                authenticationService.removeAccess();
                return transition.router.stateService.target('app.signIn', {
                    previousUri: $location.path(),
                });
            }

            if (
                transition.to().name !== 'app.ministries.signAgreements' &&
                state &&
                state.organization_with_missing_signatures_ids &&
                state.organization_with_missing_signatures_ids.length > 0
            ) {
                return transition.router.stateService.target(
                    'app.ministries.signAgreements',
                );
            }

            return loggedInPerson.loadOnce();
        });

        $transitions.onFinish({}, (transition) => {
            analyticsService.track(transition);
        });
    });
