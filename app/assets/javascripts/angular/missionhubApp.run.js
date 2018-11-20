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
        sessionStorageService,
        envService,
        facebookService,
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

        $rootScope.user = {};

        $window.fbAsyncInit = function() {
            FB.init({
                appId: envService.read('facebookAppId'),
                status: true,
                cookie: true,
                xfbml: true,
                version: 'v2.4',
            });
        };

        localStorageService.allowSessionTransfer();

        if (authenticationService.isTokenValid()) {
            authenticationService.setupAuthenticationState();
        }

        (function(d) {
            const id = 'facebook-jssdk';
            const ref = d.getElementsByTagName('script')[0];

            if (d.getElementById(id)) {
                return;
            }

            let js = d.createElement('script');
            js.id = id;
            js.async = true;
            js.src = '//connect.facebook.net/en_US/sdk.js';

            ref.parentNode.insertBefore(js, ref);
        })(document);
    });
