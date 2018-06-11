angular.module('missionhubApp').filter('t', function() {
  return function(translationKey, placeholders) {
    // return I18n.t(translationKey, placeholders);
    return translationKey;
  };
});
