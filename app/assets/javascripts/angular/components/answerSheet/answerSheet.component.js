(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('answerSheet', {
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('answerSheet');
            },
            bindings: {
                answerSheet: '<',
                organizationId: '<'
            }
        });
})();
