(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .component('organizationOverviewPeople', {
            controller: organizationOverviewPeopleController,
            require: {
                organizationOverview: '^'
            },
            templateUrl: /* @ngInject */ function (templateUrl) {
                return templateUrl('organizationOverviewPeople');
            }
        });

    function organizationOverviewPeopleController ($scope, $uibModal, organizationOverviewPeopleService,
                                                   RequestDeduper, ProgressiveListLoader, _) {
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
        vm.massEdit = massEdit;
        vm.clearSelection = clearSelection;

        var requestDeduper = new RequestDeduper();
        var listLoader = new ProgressiveListLoader('person', requestDeduper);

        $scope.$watch('$ctrl.multiSelection', function () {
            // because multiSelection is only a list of the loaded records,
            // we need to count the ones that are explicitly un-selected when
            // select all is checked
            var unselected = getUnselectedPeople().length;

            // has the user unselected all of the records?
            if (unselected === vm.totalCount) {
                vm.selectAllValue = false;
            }

            if (vm.selectAllValue) {
                vm.selectedCount = vm.totalCount - unselected;
            } else {
                vm.selectedCount = getSelectedPeople().length;
            }
        }, true);

        function loadPersonPage () {
            vm.busy = true;
            var orgId = vm.organizationOverview.org.id;
            return organizationOverviewPeopleService.loadMoreOrgPeople(orgId, vm.filters, listLoader)
                .then(function (resp) {
                    var oldPeople = vm.people;

                    vm.busy = false;
                    vm.people = resp.list;
                    vm.loadedAll = resp.loadedAll;
                    vm.totalCount = resp.total;

                    // Set the selected state of all of the new people
                    _.differenceBy(vm.people, oldPeople, 'id').forEach(function (person) {
                        vm.multiSelection[person.id] = vm.selectAllValue;
                    });
                })
                .catch(function (err) {
                    if (err.canceled) {
                        // Ignore errors that were the result of the network request being deduped
                        return;
                    }

                    vm.busy = false;
                });
        }

        // Return an array of the ids of all people with the specified selection state (true for selected, false for
        // unselected)
        function getPeopleByState (state) {
            return _.chain(vm.multiSelection)
                .pickBy(function (selected) {
                    return selected === state;
                })
                .keys()
                .value();
        }

        // Return an array of the ids of all selected people
        function getSelectedPeople () {
            return getPeopleByState(true);
        }

        // Return an array of the ids of all selected people
        function getUnselectedPeople () {
            return getPeopleByState(false);
        }

        function resetList () {
            vm.people = [];
            listLoader.reset();
            vm.loadedAll = false;
            vm.selectAllValue = false;
            vm.multiSelection = {};
        }

        function filtersChanged (newFilters) {
            vm.filters = newFilters;
            resetList();
            loadPersonPage();
        }

        function selectAll () {
            vm.people.forEach(function (person) {
                vm.multiSelection[person.id] = vm.selectAllValue;
            });
        }

        // Open a modal to mass-edit all selected people
        function massEdit () {
            var orgId = vm.organizationOverview.org.id;
            $uibModal.open({
                component: 'massEdit',
                resolve: {
                    selection: function () {
                        return {
                            orgId: orgId,
                            filters: vm.filters,
                            selectedPeople: getSelectedPeople(),
                            unselectedPeople: getUnselectedPeople(),
                            totalSelectedPeople: vm.selectedCount,
                            allSelected: vm.selectAllValue,
                            allIncluded: vm.loadedAll
                        };
                    }
                },
                windowClass: 'pivot_theme',
                size: 'sm'
            }).result.then(function () {
                $scope.$broadcast('massEditApplied');

                // Determine whether any filters are applied
                var filtersApplied = vm.filters.searchString || _.keys(vm.filters.labels).length ||
                    _.keys(vm.filters.assignedTos).length || _.keys(vm.filters.groups).length;
                if (!filtersApplied) {
                    // When there are no filters, we only need to make sure that all the people that people in the list
                    // are assigned to are loaded
                    organizationOverviewPeopleService.loadAssignedTos(vm.people, orgId);
                    return;
                }

                // When there are filters, we need to reload the entire people list because those people might not match
                // the filter anymore and we are currently choosing not to do client-side filtering

                var originalSelectAllValue = vm.selectAllValue;
                var originalMultiSelection = vm.multiSelection;

                // Empty and reload the people list
                resetList();
                loadPersonPage().then(function () {
                    // Restore the select all value and the selection states of all people that are still loaded

                    // Ignore original selection states that do not match a loaded person
                    var relevantOriginalSelections = _.pick(originalMultiSelection, _.map(vm.people, 'id'));

                    // Copy those selections to the current selection
                    _.extend(vm.multiSelection, relevantOriginalSelections);

                    // Keep the select all checkbox selected if it was originally selected and some people are selected
                    vm.selectAllValue = originalSelectAllValue && getSelectedPeople().length > 0;
                });
            });
        }

        function clearSelection () {
            vm.selectAllValue = false;
            vm.multiSelection = {};
        }
    }
})();
