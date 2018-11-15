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
        loggedInPerson,
        updateRollbarPerson,
        sessionStorageService,
        localStorageService,
        $http,
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

        const token =
            sessionStorageService.get('jwtToken') ||
            localStorageService.get('jwtToken');

        if (token) {
            $http.defaults.headers.common.Authorization = 'Bearer ' + token;
            loggedInPerson.loadOnce().then(function(me) {
                i18next.changeLanguage(me.user.language);
                updateRollbarPerson(me);
                $rootScope.legacyNavigation = me.user.beta_mode === false;
            });
        }
    });
