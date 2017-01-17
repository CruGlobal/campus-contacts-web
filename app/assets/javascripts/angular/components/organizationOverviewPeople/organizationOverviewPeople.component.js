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

    function organizationOverviewPeopleController (organizationOverviewPeopleService, $log) {
        var vm = this;
        vm.people = null;
        vm.loadPersonPage = loadPersonPage;
        vm.filtersChanged = filtersChanged;

        function loadPersonPage (page) {
            return organizationOverviewPeopleService.loadOrgPeople(vm.org.id, page);
        }

        function filtersChanged (newFilters) {
            $log.log(newFilters);

            // organizationOverviewPeopleService
            //     .loadOrgPeople(vm.org.id, {}, newFilters)
            //     .then(function (newPeople) {
            //         vm.people = newPeople;
            //     });
        }
    }
})();
