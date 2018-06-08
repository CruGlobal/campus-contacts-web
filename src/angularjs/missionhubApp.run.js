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

    // This code will run when Angular initializes, but currently we are gaining our
    // authentication from the rails host through a <preload-state> component. This means
    // that the access token isn't populated at the time of application initialization,
    // the $timeout will cause delay this execution until after the first digest.
    $timeout(function() {
      loggedInPerson.loadOnce().then(function(me) {
        updateRollbarPerson(me);
        $rootScope.legacyNavigation = me.user.beta_mode === false;
      });
    });
  });
