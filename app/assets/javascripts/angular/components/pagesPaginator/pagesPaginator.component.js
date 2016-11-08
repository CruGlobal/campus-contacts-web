(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('pagesPaginator', {
            require: {
                pages: '^pages'
            },
            templateUrl: '/assets/angular/components/pagesPaginator/pagesPaginator.html'
        });
})();
