import i18next from 'i18next';

angular.module('campusContactsApp').factory('authenticationService', authenticationService);

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
  const oktaLogoutUrl = `${envService.read('oktaUrl')}/login/signout`;

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

  const setHttpHeaders = (token) => {
    if (!token) return;
    $http.defaults.headers.common.Authorization = 'Bearer ' + token;
  };

  const clearToken = () => {
    state.v4AccessToken = null;
    localStorageService.destroy('jwtToken');
    $http.defaults.headers.common.Authorization = null;
  };

  const storeJwtToken = (token) => {
    if (!token) return;

    state.v4AccessToken = token;
    localStorageService.set('jwtToken', token);
  };

  const setAuthorizationAndState = (token) => {
    if (token) {
      storeJwtToken(token);
      setHttpHeaders(token);
      setupUserSettings();
    }
  };

  const requestFacebookV4Token = (token) =>
    $http.post(`${envService.read('apiUrl')}/auth/facebook`, {
      fb_access_token: token,
      provider: 'facebook',
    });

  const requestOktaV4Token = (token) =>
    $http.post(`${envService.read('apiUrl')}/auth/okta`, {
      okta_access_token: token,
      provider: 'okta',
    });

  const authorizeFacebookAccess = async (accessToken) => {
    try {
      const { data } = await requestFacebookV4Token(accessToken);
      setAuthorizationAndState(data.token);
      postAuthRedirect();
    } catch (e) {
      errorService.displayError(e, false);
    }
  };

  const authorizeOktaAccess = async (accessToken) => {
    try {
      const { data } = await requestOktaV4Token(accessToken);
      setAuthorizationAndState(data.token);
      postAuthRedirect();
    } catch (e) {
      errorService.displayError(e, false);
    }
  };

  const loadState = () => {
    const currentState = localStorageService.get('state');

    if (!currentState) return;

    state.hasCampusContactsAccess = currentState.hasCampusContactsAccess || currentState.hasMissionhubAccess; // hasMissionhubAccess can be deleted during another deployment 2 days after this one when user JWTs have expired and a sign in will happen again
    state.organization_with_missing_signatures_ids = currentState.organization_with_missing_signatures_ids;
    state.loggedIn = true;

    $rootScope.$broadcast('state:changed', state);
  };

  const setState = (person) => {
    const newState = {
      hasCampusContactsAccess: true,
      organization_with_missing_signatures_ids: person ? person.organization_with_missing_signatures_ids : [],
    };

    localStorageService.set('state', newState);

    loadState();
  };

  const clearState = () => {
    localStorageService.destroy('state');
    state.hasCampusContactsAccess = null;
    state.organization_with_missing_signatures_ids = null;
    state.loggedIn = false;
    JsonApiDataStore.store.reset();
    loggedInPerson.clearLoadingPromise();

    $rootScope.$broadcast('state:changed', state);
  };

  const impersonateUser = async (userId) => {
    try {
      const { data } = await $http.get(`${envService.read('apiUrl')}/impersonations/${userId}`);
      setAuthorizationAndState(data.token);
    } catch (e) {
      errorService.displayError(e, false);
    }
  };

  const stopImpersonatingUser = async () => {
    try {
      const { data } = await $http.delete(`${envService.read('apiUrl')}/impersonations`);
      setAuthorizationAndState(data.token);
    } catch (e) {
      errorService.displayError(e, false);
    }
  };

  const adminRedirect = async () => {
    const apiDomain = envService.read('apiUrl').replace('/apis/v4', '');
    try {
      await $http.post(`${apiDomain}/admin/auth`, null, {
        withCredentials: true, // support cross domain cookie setting
      });
      location.replace(`${apiDomain}/admin`);
    } catch (e) {
      $state.go('app.people');
    }
  };

  const postAuthRedirect = () => {
    const { previousUri } = $location.search();
    if (previousUri) {
      $location.url(previousUri);
      $location.replace();
    } else {
      $state.go('app.people');
    }
  };

  return {
    destroyOktaAccess: () => {
      clearToken();
      clearState();
      $window.location.href = oktaLogoutUrl;
    },
    authorizeFacebookAccess,
    authorizeOktaAccess,
    storeJwtToken,
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
    impersonateUser,
    stopImpersonatingUser,
    adminRedirect,
    postAuthRedirect,
    isTokenValid: getJwtToken,
    updateUserData,
  };
}
