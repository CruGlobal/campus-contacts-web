(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('statsHeader', {
            controller: statsHeaderController,
            bindings: {
                title: '<'
            },
            templateUrl: '/assets/angular/components/statsHeader/statsHeader.html'
        });

    function statsHeaderController () {
    }
})();
