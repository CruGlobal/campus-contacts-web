angular
    .module('missionhubApp')
    .factory('authenticationService', authenticationService);

function authenticationService(
    envService,
    $http,
    $rootScope,
    updateRollbarPerson,
    $state,
    state,
    sessionStorageService,
    localStorageService,
) {
    const service = `${envService.read('apiUrl')}/auth/thekey`;
    const redirectUrl = encodeURIComponent(
        envService.read('siteUrl') + '/auth',
    );
    const theKeyloginUrl = `${envService.read(
        'theKeyUrl',
    )}/login?response_type=token&scope=fullticket&state=randomData&client_id=${envService.read(
        'theKeyClientId',
    )}&redirect_uri=${redirectUrl}`;

    const getJwtToken = () => {
        return (
            sessionStorageService.get('jwtToken') ||
            localStorageService.get('jwtToken') ||
            false
        );
    };

    const setupUserSettings = async () => {
        const me = await loggedInPerson.loadOnce();

        i18next.changeLanguage(me.user.language);
        updateRollbarPerson(me);
        $rootScope.legacyNavigation = me.user.beta_mode === false;
    };

    const setHttpHeaders = token => {
        if (!token) return;
        $http.defaults.headers.common.Authorization = 'Bearer ' + token;
    };

    const clearToken = () => {
        state.v4AccessToken = null;
        sessionStorageService.clear('jwtToken');
        localStorageService.clear('jwtToken');
    };

    const storeToken = token => {
        if (!token) return;

        state.v4AccessToken = token;
        sessionStorageService.set('jwtToken', token);

        if (envService.is('development'))
            localStorageService.set('jwtToken', token);
    };

    const setAuthorizationAndState = (token, organization) => {
        setState(organization);

        if (token) {
            storeToken(token);
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

    const authorizeAccess = async accessToken => {
        const response = await requestTicket(accessToken);
        const { data } = await requestV4Token(response.data.ticket);

        setAuthorizationAndState(data.token, data.recent_organization);

        $state.go('app.people');
    };

    const loadState = () => {
        const currentState =
            sessionStorageService.get('state') ||
            localStorageService.get('state');

        if (!currentState) return;

        state.hasMissionhubAccess = currentState.hasMissionhubAccess;
        state.currentOrganization = currentState.currentOrganization;
    };

    const setState = organization => {
        const newState = {
            hasMissionhubAccess: true,
            currentOrganization: organization ? organization.id : 0,
        };

        sessionStorageService.set('state', newState);

        if (envService.is('development'))
            localStorageService.set('state', newState);

        loadState();
    };

    const clearState = () => {
        sessionStorageService.clear('state');
        localStorageService.clear('state');
        state.hasMissionhubAccess = null;
        state.currentOrganization = null;
    };

    return {
        authorizeAccess: authorizeAccess,
        removeAccess: () => {
            clearToken();
            clearState();
            $state.go('login');
        },
        setupAuthenticationState: () => {
            const token = getJwtToken();

            if (!token) return;

            setHttpHeaders(token);
            loadState();
        },
        theKeyloginUrl: theKeyloginUrl,
        isTokenValid: () => {
            return getJwtToken();
        },
    };
}
