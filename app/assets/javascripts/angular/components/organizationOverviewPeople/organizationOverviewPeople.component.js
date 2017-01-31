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

    function organizationOverviewPeopleController (organizationOverviewPeopleService, RequestDeduper) {
        var vm = this;
        vm.people = [];
        vm.filters = {};
        vm.loadedAll = false;
        vm.busy = false;

        vm.loadPersonPage = loadPersonPage;
        vm.filtersChanged = filtersChanged;

        var requestDeduper = new RequestDeduper();

        function loadPersonPage () {
            vm.busy = true;
            organizationOverviewPeopleService.loadMoreOrgPeople(vm.org.id, vm.people, vm.filters, requestDeduper)
                .then(function (resp) {
                    vm.busy = false;
                    vm.people = resp.people;
                    vm.loadedAll = resp.loadedAll;
                })
                .catch(function (err) {
                    if (err.canceled) {
                        // Ignore errors that were the result of the network request being deduped
                        return;
                    }

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
