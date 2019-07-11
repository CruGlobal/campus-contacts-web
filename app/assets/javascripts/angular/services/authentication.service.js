import i18next from 'i18next';

angular
    .module('missionhubApp')
    .factory('authenticationService', authenticationService);

function authenticationService(
    envService,
    $http,
    $location,
    $rootScope,
    updateRollbarPerson,
    $state,
    state,
    sessionStorageService,
    localStorageService,
    loggedInPerson,
    errorService,
    $window,
    JsonApiDataStore,
) {
    const service = `${envService.read('apiUrl')}/auth/thekey`;
    const port = envService.is('development') ? `:${$location.port()}` : '';
    const redirectUrl = encodeURIComponent(
        `https://${$location.host()}${port}/auth-web`,
    );
    const theKeyloginUrl = `${envService.read(
        'theKeyUrl',
    )}/login?response_type=token&scope=fullticket&client_id=${envService.read(
        'theKeyClientId',
    )}&redirect_uri=${redirectUrl}`;

    const theKeySignUpUrl = `${theKeyloginUrl}?&action=signup`;

    const theKeylogoutUrl = `${envService.read(
        'theKeyUrl',
    )}/logout?&client_id=${envService.read(
        'theKeyClientId',
    )}&service=https://${$location.host()}${port}/sign-in`;

    const getJwtToken = () => {
        return localStorageService.get('jwtToken') || false;
    };

    const updateUserData = async () => {
        const me = await loggedInPerson.load();

        setState(me);
    };

    const setupUserSettings = async () => {
        JsonApiDataStore.store.reset();
        const me = await loggedInPerson.load();
        setState(me);
        i18next.changeLanguage(me.user.language);
        updateRollbarPerson(me);
    };

    const setHttpHeaders = token => {
        if (!token) return;
        $http.defaults.headers.common.Authorization = 'Bearer ' + token;
    };

    const clearToken = () => {
        state.v4AccessToken = null;
        localStorageService.destroy('jwtToken');
        $http.defaults.headers.common.Authorization = null;
    };

    const storeJwtToken = token => {
        if (!token) return;

        state.v4AccessToken = token;
        localStorageService.set('jwtToken', token);
    };

    const setAuthorizationAndState = token => {
        if (token) {
            storeJwtToken(token);
            setHttpHeaders(token);
            setupUserSettings();
        }
    };

    const requestTicket = accesstoken =>
        $http({
            method: 'GET',
            url: `${envService.read(
                'theKeyUrl',
            )}/api/oauth/ticket?service=${service}`,
            headers: {
                Authorization: `Bearer ${accesstoken}`,
            },
        });

    const requestV4Token = ticket =>
        $http.post(`${envService.read('apiUrl')}/auth/thekey`, {
            code: ticket,
        });

    const requestFacebookV4Token = token =>
        $http.post(`${envService.read('apiUrl')}/auth/facebook`, {
            fb_access_token: token,
            provider: 'facebook',
        });

    const authorizeAccess = async accessToken => {
        try {
            const response = await requestTicket(accessToken);
            const { data } = await requestV4Token(response.data.ticket);
            setAuthorizationAndState(data.token);
            const inviteState = sessionStorageService.get('inviteState');

            inviteState
                ? $state.go('appWithoutMenus.inviteLink', inviteState)
                : $state.go('app.people');
        } catch (e) {
            errorService.displayError(e, false);
        }
    };

    const authorizeFacebookAccess = async accessToken => {
        try {
            const { data } = await requestFacebookV4Token(accessToken);
            setAuthorizationAndState(data.token);
            $state.go('app.people');
        } catch (e) {
            errorService.displayError(e, false);
        }
    };

    const loadState = () => {
        const currentState = localStorageService.get('state');

        if (!currentState) return;

        state.hasMissionhubAccess = currentState.hasMissionhubAccess;
        state.organization_with_missing_signatures_ids =
            currentState.organization_with_missing_signatures_ids;
        state.loggedIn = true;

        $rootScope.$broadcast('state:changed', state);
    };

    const setState = person => {
        const newState = {
            hasMissionhubAccess: true,
            organization_with_missing_signatures_ids: person
                ? person.organization_with_missing_signatures_ids
                : [],
        };

        localStorageService.set('state', newState);

        loadState();
    };

    const clearState = () => {
        localStorageService.destroy('state');
        state.hasMissionhubAccess = null;
        state.organization_with_missing_signatures_ids = null;
        state.loggedIn = false;
        JsonApiDataStore.store.reset();
        loggedInPerson.clearLoadingPromise();

        $rootScope.$broadcast('state:changed', state);
    };

    const impersonateUser = async userId => {
        try {
            const { data } = await $http.get(
                `${envService.read('apiUrl')}/impersonations/${userId}`,
            );
            setAuthorizationAndState(data.token);
        } catch (e) {
            errorService.displayError(e, false);
        }
    };

    const stopImpersonatingUser = async () => {
        try {
            const { data } = await $http.delete(
                `${envService.read('apiUrl')}/impersonations`,
            );
            setAuthorizationAndState(data.token);
        } catch (e) {
            errorService.displayError(e, false);
        }
    };

    return {
        destroyTheKeyAccess: () => {
            clearToken();
            clearState();
            $window.location.href = theKeylogoutUrl;
        },
        authorizeAccess: authorizeAccess,
        authorizeFacebookAccess: authorizeFacebookAccess,
        storeJwtToken: storeJwtToken,
        removeAccess: () => {
            clearToken();
            clearState();
            $state.go('app.signIn');
        },
        setupAuthenticationState: () => {
            const token = getJwtToken();

            if (!token) return;

            setHttpHeaders(token);
            loadState();
        },
        impersonateUser: impersonateUser,
        stopImpersonatingUser: stopImpersonatingUser,
        theKeyloginUrl: theKeyloginUrl,
        theKeySignUpUrl: theKeySignUpUrl,
        isTokenValid: getJwtToken,
        updateUserData: updateUserData,
    };
}
