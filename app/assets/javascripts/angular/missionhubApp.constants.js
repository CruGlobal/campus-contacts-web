(function () {
    'use strict';

    /* eslint angular/window-service: "off" */

    angular
        .module('missionhubApp')
        .constant('_', window._)
        .constant('lscache', window.lscache)
        .constant('moment', window.moment)
        .constant('I18n', window.I18n)
        .constant('confirm', window.confirm)
        .constant('jQuery', window.jQuery)
        .constant('nativeLocation', window.location)
        .constant('p2cOrgId', '8411')
        .constant('spaPage', window.location.pathname === '/' || /^\/d(\/.*)?$/.test(window.location.pathname))
        .constant('rollbar', window.rollbar)
        .constant('rollbarAccessToken', 'e749b290a241465b9e70c9cf93124721');
})();
