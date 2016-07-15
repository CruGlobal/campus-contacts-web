(function() {
    'use strict';
    /* eslint angular/window-service: "off" */

    angular
        .module('missionhubApp')
        .constant('_', window._)
        .constant('lscache', window.lscache);
})();
