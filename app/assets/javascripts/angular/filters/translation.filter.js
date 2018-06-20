angular.module('missionhubApp').filter('t', function(I18n) {
    return function(translationKey, placeholders) {
        return I18n.t(translationKey, placeholders);
    };
});
