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

    const getJwtToken = () => {
        return (
            (envService.is('development') && !$window.__karma__
                ? localStorageService.get('jwtToken')
                : sessionStorageService.get('jwtToken')) || false
        );
    };

    const setupUserSettings = async () => {
        const me = await loggedInPerson.loadOnce();

        i18next.changeLanguage(me.user.language);
        updateRollbarPerson(me);
    };

    const setHttpHeaders = token => {
        if (!token) return;
        $http.defaults.headers.common.Authorization = 'Bearer ' + token;
    };

    const clearToken = () => {
        state.v4AccessToken = null;
        sessionStorageService.clear('jwtToken');
        localStorageService.clear('jwtToken');
        $http.defaults.headers.common.Authorization = null;
    };

    const storeJwtToken = token => {
        if (!token) return;

        state.v4AccessToken = token;
        sessionStorageService.set('jwtToken', token);

        if (envService.is('development') && !$window.__karma__)
            localStorageService.set('jwtToken', token);
    };

    const setAuthorizationAndState = (token, organization) => {
        setState(organization);

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
            setAuthorizationAndState(data.token, data.recent_organization);
            $state.go('app.people');
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
        state.loggedIn = true;

        $rootScope.$broadcast('state:changed', state);
    };

    const setState = organization => {
        const newState = {
            hasMissionhubAccess: true,
            currentOrganization: organization ? organization.id : 0,
        };

        sessionStorageService.set('state', newState);

        if (envService.is('development') && !$window.__karma__)
            localStorageService.set('state', newState);

        loadState();
    };

    const clearState = () => {
        sessionStorageService.clear('state');
        localStorageService.clear('state');
        state.hasMissionhubAccess = null;
        state.currentOrganization = null;
        state.loggedIn = false;

        $rootScope.$broadcast('state:changed', state);
    };

    return {
        authorizeAccess: authorizeAccess,
        authorizeFacebookAccess: authorizeFacebookAccess,
        storeJwtToken: storeJwtToken,
        removeAccess: () => {
            clearToken();
            clearState();
            $state.go('signIn');
        },
        setupAuthenticationState: () => {
            const token = getJwtToken();

            if (!token) return;

            setHttpHeaders(token);
            loadState();
        },
        theKeyloginUrl: theKeyloginUrl,
        isTokenValid: getJwtToken,
    };
}
