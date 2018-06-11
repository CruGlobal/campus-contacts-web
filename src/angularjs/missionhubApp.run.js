import lscache from 'lscache';

angular
  .module('missionhubApp')
  .run(function(
    $window,
    $rootScope,
    $analytics,
    $timeout,
    spaPage,
    loggedInPerson,
    updateRollbarPerson,
    $http,
  ) {
    lscache.setBucket('missionhub:');

    $http.defaults.headers.common.Authorization =
      'Bearer ' + $window.localStorage.getItem('missionhubV4AccessToken');

    // Determine whether this page is a SPA page or a legacy page
    $rootScope.isSpaPage = spaPage;
    $rootScope.isLegacyPage = !$rootScope.isSpaPage;

    if ($rootScope.isLegacyPage) {
      $analytics.pageTrack($window.location.pathname);
    }

    loggedInPerson.loadOnce().then(function(me) {
      updateRollbarPerson(me);
      $rootScope.legacyNavigation = me.user.beta_mode === false;
    });
  });
