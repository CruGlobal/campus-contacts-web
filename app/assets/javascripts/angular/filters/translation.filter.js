(function() {
    'use strict';

    angular.module('missionhubApp')
        .filter('t', function (I18n) {
            return function (translationKey) {
                return I18n.t(translationKey);
            };
        });
})();
