(function () {
    'use strict';
    /* eslint angular/window-service: "off" */

    angular
        .module('missionhubApp')
        .constant('_', window._)
        .constant('lscache', window.lscache)
        .constant('I18n', window.I18n)
        .constant('confirm', window.confirm)
        .constant('jQuery', window.jQuery)
        .constant('nativeLocation', window.location);
})();
