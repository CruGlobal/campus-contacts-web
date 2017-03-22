(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('asyncContent', {
            bindings: {
                ready: '<'
            },
            templateUrl: '/assets/angular/components/asyncContent/asyncContent.html',
            transclude: true
        });
})();
