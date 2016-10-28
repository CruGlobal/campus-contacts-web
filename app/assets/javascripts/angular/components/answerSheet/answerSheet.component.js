(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('answerSheet', {
            templateUrl: '/assets/angular/components/answerSheet/answerSheet.html',
            bindings: {
                answerSheet: '<'
            }
        });
})();
