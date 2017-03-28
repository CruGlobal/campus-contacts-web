(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('asyncContent', {
            bindings: {
                ready: '<'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('asyncContent');
            },
            transclude: true
        });
})();
