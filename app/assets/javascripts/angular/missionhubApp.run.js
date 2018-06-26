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

        // This code will run when Angular initializes, but currently we are gaining our
        // authentication from the rails host through a <preload-state> component. This means
        // that the access token isn't populated at the time of application initialization,
        // the $timeout will cause delay this execution until after the first digest.
        $timeout(function() {
            loggedInPerson.loadOnce().then(function(me) {
                i18next.changeLanguage(me.user.language);
                updateRollbarPerson(me);
                $rootScope.legacyNavigation = me.user.beta_mode === false;
            });
        });
    });
