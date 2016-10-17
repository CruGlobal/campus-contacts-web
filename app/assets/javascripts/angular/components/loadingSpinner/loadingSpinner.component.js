(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('loadingSpinner', {
            bindings: {
                size: '<'
            },
            templateUrl: '/assets/angular/components/loadingSpinner/loadingSpinner.html'
        });
})();
