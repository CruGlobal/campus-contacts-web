angular.module('campusContactsApp').factory('facebookService', facebookService);

function facebookService(authenticationService, envService) {
    return {
        init: () => {
            FB.init({
                appId: envService.read('facebookAppId'),
                status: true,
                cookie: true,
                xfbml: true,
                version: 'v7.0',
            });
        },
        loadSDK: () => {
            return function (d) {
                const id = 'facebook-jssdk';
                const fjs = d.getElementsByTagName('script')[0];

                if (d.getElementById(id)) {
                    return;
                }

                const js = d.createElement('script');
                js.id = id;
                js.async = true;
                js.src = 'https://connect.facebook.net/en_US/sdk.js';

                fjs.parentNode.insertBefore(js, fjs);
            };
        },
        signOut: () => {
            FB.logout((response) => {});
        },
        signIn: () => {
            FB.login(
                (response) => {
                    if (response.authResponse) {
                        authenticationService.authorizeFacebookAccess(
                            response.authResponse.accessToken,
                        );
                    } else {
                        throw new Error(
                            'User cancelled login or did not fully authorize.',
                        );
                    }
                },
                { scope: 'email' },
            );
        },
    };
}
