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
        .constant('p2cOrgId', '7311')
        .constant('spaPage', window.location.pathname === '/' || /^\/d(\/.*)?$/.test(window.location.pathname));
})();
