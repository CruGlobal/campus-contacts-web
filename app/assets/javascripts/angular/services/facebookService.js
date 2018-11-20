angular.module('missionhubApp').factory('facebookService', facebookService);

function facebookService(authenticationService) {
    return {
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
