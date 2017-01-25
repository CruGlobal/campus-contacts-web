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
        vm.people = [];
        vm.filters = {};

        vm.loadPersonPage = loadPersonPage;
        vm.filtersChanged = filtersChanged;

        function loadPersonPage () {
            if (vm.busy) {
                return;
            }
            vm.busy = true;

            organizationOverviewPeopleService.loadMoreOrgPeople(vm.org.id, vm.people, vm.filters)
                .then(function (resp) {
                    vm.people = resp.people;
                    vm.loadedAll = resp.loadedAll;
                })
                .finally(function () {
                    vm.busy = false;
                });
        }

        function filtersChanged (newFilters) {
            vm.filters = newFilters;
            vm.people = [];
            vm.loadedAll = false;

            loadPersonPage();
        }
    }
})();
