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
        state,
        loggedInPerson,
        $uibModal,
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
            authenticationService.updateUserData();

            loggedInPerson.loadOnce().then(user => {
                if (user.beta_mode === null) {
                    $uibModal.open({
                        component: 'newWelcomeModal',
                        resolve: {},
                        windowClass: 'pivot_theme',
                        size: 'sm',
                    });
                }
            });
        }

        facebookService.loadSDK()(document);

        analyticsService.init();

        $transitions.onBefore({}, transition => {
            if (transition.to().data && transition.to().data.isPublic)
                return true;

            if (!authenticationService.isTokenValid()) {
                authenticationService.removeAccess();
                return transition.router.stateService.target('app.signIn');
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
        });

        $transitions.onFinish({}, transition => {
            analyticsService.track(transition);
        });
    });
