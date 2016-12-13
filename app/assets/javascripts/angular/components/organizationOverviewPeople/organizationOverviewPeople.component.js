(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewPeople', {
            controller: organizationOverviewPeopleController,
            bindings: {
                org: '<'
            },
            templateUrl: '/assets/angular/components/organizationOverviewPeople/organizationOverviewPeople.html'
        });

    function organizationOverviewPeopleController (organizationOverviewPeopleService) {
        var vm = this;
        vm.people = null;
        vm.loadPersonPage = loadPersonPage;

        function loadPersonPage (page) {
            return organizationOverviewPeopleService.loadOrgPeople(vm.org.id, page);
        }
    }
})();
