angular.module('campusContactsApp').factory('oktaService', oktaService);

let idToken = 'none';
let accessToken = 'none';

function setIdToken(token) {
    idToken = token;
}

function setAccessToken(token) {
    accessToken = token;
}

function oktaService(authenticationService, envService) {
    const authClient = new OktaAuth({
        issuer: 'https://signon.okta.com/oauth2/default',
        clientId: envService.read('oktaClientId'),
        pkce: true,
        tokenManager: {
            secure: true,
        },
        devMode: true,
    });

    return {
        init: () => {
            authClient.start();
        },
        signOut: () => {
            authClient.signOut();
        },
        signIn: async () => {
            // There are other options like full page redirects or passing username/password directly but this seemed like the nicest to me.
            const response = await authClient.token.getWithPopup({
                scopes: ['openid', 'email', 'profile'],
            });

            setIdToken(response.tokens.idToken.value);
            setAccessToken(response.tokens.accessToken.value);
            authClient.tokenManager.add('idToken', response.tokens.idToken);
            authClient.tokenManager.add(
                'accessToken',
                response.tokens.accessToken,
            );

            authenticationService.authorizeOktaAccess(
                response.tokens.accessToken.accessToken,
            );
        },
    };
}
