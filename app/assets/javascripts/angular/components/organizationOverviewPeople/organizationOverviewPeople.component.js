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

    function organizationOverviewPeopleController ($scope, organizationOverviewPeopleService, RequestDeduper, _) {
        var vm = this;
        vm.people = [];
        vm.multiSelection = {};
        vm.filters = {};
        vm.loadedAll = false;
        vm.busy = false;
        vm.selectedCount = 0;
        vm.totalCount = 0;

        // represents if the user has checked the "Select All" checkbox
        vm.selectAllValue = false;

        vm.loadPersonPage = loadPersonPage;
        vm.filtersChanged = filtersChanged;
        vm.selectAll = selectAll;

        var requestDeduper = new RequestDeduper();

        $scope.$watch('$ctrl.multiSelection', function () {
            // because multiSelection is only a list of the loaded records,
            // we need to count the ones that are explicitly un-selected when
            // select all is checked
            var unselected = _.chain(vm.multiSelection)
                .pickBy(function (v) {
                    return !v;
                })
                .keys()
                .value()
                .length;

            // has the user unselected all of the records?
            if (unselected === vm.totalCount) {
                vm.selectAllValue = false;
            }

            if (vm.selectAllValue) {
                vm.selectedCount = vm.totalCount - unselected;
            } else {
                vm.selectedCount = _.chain(vm.multiSelection)
                    .pickBy()
                    .keys()
                    .value()
                    .length;
            }
        }, true);

        function loadPersonPage () {
            vm.busy = true;
            organizationOverviewPeopleService.loadMoreOrgPeople(vm.org.id, vm.people, vm.filters, requestDeduper)
                .then(function (resp) {
                    vm.busy = false;
                    vm.people = resp.people;
                    vm.loadedAll = resp.loadedAll;
                    vm.totalCount = resp.total;

                    if (vm.selectAllValue) {
                        addSelection(resp.people);
                    }
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
            vm.selectAllValue = false;
            vm.multiSelection = {};

            loadPersonPage();
        }

        function selectAll () {
            if (!vm.selectAllValue) {
                vm.multiSelection = {};
                return;
            }
            addSelection(vm.people, true);
        }

        function addSelection (people, force) {
            people.forEach(function (person) {
                if (force || _.isUndefined(vm.multiSelection[person.id])) {
                    vm.multiSelection[person.id] = true;
                }
            });
        }
    }
})();
