(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('navSearch', {
            controller: navSearchController,
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('nav-search');
            }
        });

    function navSearchController (peopleSearchService) {
        var vm = this;

        vm.searchPeople = peopleSearchService.search;
    }
})();
