angular.module('missionhubApp').factory('facebookService', facebookService);

function facebookService(authenticationService, envService) {
    return {
        init: () => {
            FB.init({
                appId: envService.read('facebookAppId'),
                status: true,
                cookie: true,
                xfbml: true,
                version: 'v2.4',
            });
        },
        loadSDK: () => {
            return function(d) {
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
            };
        },
        signOut: () => {
            FB.logout(response => {});
        },
        signIn: () => {
            FB.login(response => {
                if (response.authResponse) {
                    authenticationService.authorizeFacebookAccess(
                        response.authResponse.accessToken,
                    );
                } else {
                    throw new Error(
                        'User cancelled login or did not fully authorize.',
                    );
                }
            });
        },
    };
}
