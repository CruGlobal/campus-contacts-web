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
        `https://${$location.host()}${port}/auth`,
    );
    const theKeyloginUrl = `${envService.read(
        'theKeyUrl',
    )}/login?response_type=token&scope=fullticket&client_id=${envService.read(
        'theKeyClientId',
    )}&redirect_uri=${redirectUrl}`;
    let loaded = false;

    const getJwtToken = () => {
        return (
            (envService.is('development')
                ? localStorageService.get('jwtToken')
                : sessionStorageService.get('jwtToken')) || false
        );
    };

    const updateUserData = async () => {
        const me = await loggedInPerson.load();

        const currentState = envService.is('development')
            ? localStorageService.get('state')
            : sessionStorageService.get('state');

        setState(currentState.currentOrganization, me);
    };

    const setupUserSettings = async organization => {
        JsonApiDataStore.store.reset();
        const me = await loggedInPerson.load();
        setState(organization, me);
        i18next.changeLanguage(me.user.language);
        updateRollbarPerson(me);
    };

    const setHttpHeaders = token => {
        if (!token) return;
        $http.defaults.headers.common.Authorization = 'Bearer ' + token;
    };

    const clearToken = () => {
        state.v4AccessToken = null;
        sessionStorageService.destroy('jwtToken');
        localStorageService.destroy('jwtToken');
        $http.defaults.headers.common.Authorization = null;
    };

    const storeJwtToken = token => {
        if (!token) return;

        state.v4AccessToken = token;
        sessionStorageService.set('jwtToken', token);

        if (envService.is('development'))
            localStorageService.set('jwtToken', token);
    };

    const setAuthorizationAndState = (token, organization) => {
        if (token) {
            storeJwtToken(token);
            setHttpHeaders(token);
            setupUserSettings(organization);
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
            setAuthorizationAndState(data.token, data.recent_organization);
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
            setAuthorizationAndState(data.token, data.recent_organization);
            $state.go('app.people');
        } catch (e) {
            errorService.displayError(e, false);
        }
    };

    const loadState = () => {
        const currentState = envService.is('development')
            ? localStorageService.get('state')
            : sessionStorageService.get('state');

        if (!currentState) return;

        state.hasMissionhubAccess = currentState.hasMissionhubAccess;
        state.currentOrganization = currentState.currentOrganization;
        state.organization_with_missing_signatures_ids =
            currentState.organization_with_missing_signatures_ids;
        state.loggedIn = true;

        $rootScope.$broadcast('state:changed', state);

        loaded = true;
    };

    const setState = (organization, person) => {
        const newState = {
            hasMissionhubAccess: true,
            currentOrganization: organization ? organization.id : 0,
            organization_with_missing_signatures_ids: person
                ? person.organization_with_missing_signatures_ids
                : [],
        };

        sessionStorageService.set('state', newState);

        if (envService.is('development'))
            localStorageService.set('state', newState);

        loadState();
    };

    const clearState = () => {
        sessionStorageService.destroy('state');
        localStorageService.destroy('state');
        state.hasMissionhubAccess = null;
        state.currentOrganization = null;
        state.organization_with_missing_signatures_ids = null;
        state.loggedIn = false;
        JsonApiDataStore.store.reset();
        loaded = false;
        $rootScope.$broadcast('state:changed', state);
    };

    const impersonateUser = async userId => {
        try {
            const { data } = await $http.get(
                `${envService.read('apiUrl')}/impersonations/${userId}`,
            );
            setAuthorizationAndState(data.token, data.recent_organization);
        } catch (e) {
            errorService.displayError(e, false);
        }
    };

    const stopImpersonatingUser = async () => {
        try {
            const { data } = await $http.delete(
                `${envService.read('apiUrl')}/impersonations`,
            );
            setAuthorizationAndState(data.token, data.recent_organization);
        } catch (e) {
            errorService.displayError(e, false);
        }
    };

    return {
        authorizeAccess: authorizeAccess,
        authorizeFacebookAccess: authorizeFacebookAccess,
        loaded: () => loaded,
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
        isTokenValid: getJwtToken,
        updateUserData: updateUserData,
    };
}
