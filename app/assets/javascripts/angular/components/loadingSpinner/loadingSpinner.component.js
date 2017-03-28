(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('loadingSpinner', {
            bindings: {
                size: '<'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('loadingSpinner');
            }
        });
})();
