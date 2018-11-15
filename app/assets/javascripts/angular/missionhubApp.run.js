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
        spaPage,
        loggedInPerson,
        updateRollbarPerson,
        sessionStorageService,
        localStorageService,
        $http,
    ) {
        lscache.setBucket('missionhub:');

        // Determine whether this page is a SPA page or a legacy page
        $rootScope.isSpaPage = spaPage;
        $rootScope.isLegacyPage = !$rootScope.isSpaPage;

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
