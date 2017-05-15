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

    function organizationOverviewPeopleController ($rootScope, $scope, $filter, $uibModal, confirmModalService,
                                                   organizationOverviewPeopleService, personService,
                                                   peopleFiltersPanelService,
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
        vm.setSortColumn = setSortColumn;
        vm.selectAll = selectAll;
        vm.massEdit = massEdit;
        vm.mergeable = mergeable;
        vm.merge = merge;
        vm.sendMessage = sendMessage;
        vm.exportPeople = exportPeople;
        vm.transferPeople = transferPeople;
        vm.archivePeople = archivePeople;
        vm.deletePeople = deletePeople;
        vm.clearSelection = clearSelection;

        vm.$onInit = activate;
        vm.$onDestroy = deactivate;

        var requestDeduper = new RequestDeduper();
        var listLoader = new ProgressiveListLoader({
            modelType: 'person',
            requestDeduper: requestDeduper,
            errorMessage: 'error.messages.organization_overview_people.load_people_chunk'
        });

        // Define the columns that can be selected as sort keys
        // The "getSortKey" method returns the value that a person should be sorted by when sorting by that column
        vm.columns = [
            {
                name: 'name',
                cssClass: 'name-column',
                label: 'ministries.people.name',
                sortable: true,
                getSortKey: function (person) {
                    return [person.last_name.toLowerCase(), person.first_name.toLowerCase()];
                },
                orderFields: ['last_name', 'first_name']
            }, {
                name: 'gender',
                cssClass: 'detail-column gender-column',
                label: 'ministries.people.gender',
                sortable: true,
                getSortKey: function (person) {
                    return person.gender;
                },
                orderFields: ['gender', 'last_name', 'first_name']
            }, {
                name: 'assignment',
                cssClass: 'detail-column assigned-to-column',
                label: 'assignments.assignment',
                sortable: false
            }, {
                name: 'status',
                cssClass: 'detail-column status-column',
                label: 'ministries.people.status',
                sortable: true,
                getSortKey: function (person) {
                    return personService.getFollowupStatus(person, vm.organizationOverview.org.id);
                },
                orderFields: ['followup_status', 'last_name', 'first_name']
            }
        ];

        var defaultSortOrder = { column: vm.columns[0], direction: 'asc' };

        vm.$onInit = activate;

        var unsubscribe = null;

        function activate () {
            unsubscribe = $rootScope.$on('personCreated', function (event, person) {
                onNewPerson(person);
            });

            vm.sortOrder = _.clone(defaultSortOrder);
        }

        function deactivate () {
            unsubscribe();
        }

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

            // Generate the sort order list
            return organizationOverviewPeopleService.loadMoreOrgPeople(orgId, vm.filters, getOrder(), listLoader)
                .then(function (resp) {
                    var oldPeople = vm.people;

                    vm.people = resp.list;
                    vm.loadedAll = resp.loadedAll;
                    vm.totalCount = resp.total;

                    // Set the selected state of all of the new people
                    _.differenceBy(vm.people, oldPeople, 'id').forEach(function (person) {
                        vm.multiSelection[person.id] = vm.selectAllValue;
                    });
                })
                .finally(function () {
                    vm.busy = false;
                });
        }

        // Respond to the creation of a new person by potentially adding it to the person list, updating counts, etc.
        function onNewPerson (person) {
            // If filters are applied, then refresh the list because the new person may or may not be included
            // in the person list. If no filters applied, simply add it to the person list.
            if (peopleFiltersPanelService.filtersHasActive(vm.filters)) {
                resetList();
                loadPersonPage();
            } else {
                vm.people.push(person);
                vm.totalCount++;
                vm.multiSelection[person.id] = vm.selectAllValue;
            }

            // Update the people count shown in the people tab
            if (vm.organizationOverview.people) {
                vm.organizationOverview.people.length++;
            }
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

        function setSortColumn (column) {
            if (vm.sortOrder.column === column) {
                if (vm.sortOrder.direction === 'asc') {
                    vm.sortOrder.direction = 'desc';
                } else if (vm.sortOrder.direction === 'desc') {
                    vm.sortOrder = _.clone(defaultSortOrder);
                }
            } else {
                vm.sortOrder.column = column;
                vm.sortOrder.direction = 'asc';
            }

            // Reload the list of people using the new sort order
            resetList();
            loadPersonPage();
        }

        function selectAll () {
            vm.people.forEach(function (person) {
                vm.multiSelection[person.id] = vm.selectAllValue;
            });
        }

        // Get the current selection in a standard form
        function getSelection () {
            return {
                orgId: vm.organizationOverview.org.id,
                filters: vm.filters,
                selectedPeople: getSelectedPeople(),
                unselectedPeople: getUnselectedPeople(),
                totalSelectedPeople: vm.selectedCount,
                allSelected: vm.selectAllValue,
                allIncluded: vm.loadedAll
            };
        }

        // Get the current sort order
        function getOrder () {
            return vm.sortOrder.column.orderFields.map(function (fieldName) {
                return { field: fieldName, direction: vm.sortOrder.direction };
            });
        }

        // Open a modal to mass-edit all selected people
        function massEdit () {
            $uibModal.open({
                component: 'massEdit',
                resolve: {
                    selection: _.constant(getSelection())
                },
                windowClass: 'pivot_theme',
                size: 'sm'
            }).result.then(function () {
                $scope.$broadcast('massEditApplied');

                // Determine whether any filters are applied
                if (!peopleFiltersPanelService.filtersHasActive(vm.filters)) {
                    // When there are no filters, we only need to make sure that all the people that people in the list
                    // are assigned to are loaded
                    organizationOverviewPeopleService.loadAssignedTos(vm.people, vm.organizationOverview.org.id);
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

        // Return a boolean indicating whether the selected people can be merged
        function mergeable () {
            // Only 2 - 4 people may be merged at a time
            return vm.selectedCount >= 2 && vm.selectedCount <= 4;
        }

        function merge () {
            if (!mergeable()) {
                return;
            }

            var personIds = getSelectedPeople();
            $uibModal.open({
                component: 'mergeWinnerModal',
                resolve: {
                    choices: _.constant(personIds)
                },
                windowClass: 'pivot_theme',
                size: 'md'
            }).result.then(function (winner) {
                return organizationOverviewPeopleService.mergePeople(personIds, winner.id).then(function () {
                    removePeopleFromList(_.without(personIds, winner.id));
                });
            });
        }

        function sendMessage (medium) {
            $uibModal.open({
                component: 'messageModal',
                resolve: {
                    medium: _.constant(medium),
                    selection: _.constant(getSelection())
                },
                windowClass: 'pivot_theme',
                size: 'md'
            });
        }

        // Remove the specified people from the people list in the UI
        function removePeopleFromList (peopleIds) {
            // Partition loaded people by whether or not they are removed
            var partition = _.partition(vm.people, function (person) {
                return _.includes(peopleIds, person.id);
            });
            var removedPeople = partition[0];
            var remainingPeople = partition[1];

            // Update the people list and count
            vm.people = remainingPeople;
            vm.totalCount -= removedPeople.length;
            listLoader.reset(vm.people);

            // Update the people count shown in the people tab
            if (vm.organizationOverview.people) {
                vm.organizationOverview.people.length -= removedPeople.length;
            }

            // Remove the selection state of removed people
            removedPeople.forEach(function (person) {
                delete vm.multiSelection[person.id];
            });

            // Instruct the infinite scroller to check whether more people should be loaded because after
            // removing some people, the list will be shorter and may now be at the bottom. However, do this in
            // the next digest cycle after all of the removed people have been removed from the UI.
            $scope.$applyAsync(function () {
                $scope.$emit('checkInfiniteScroll');
            });

            $scope.$broadcast('massEditApplied');
        }

        // Remove the selected people
        // This is an abstract method that can both archive and remove people
        function removePeople (message, performRemoval) {
            var selection = getSelection();
            confirmModalService.create($filter('t')(message, { contact_count: vm.selectedCount }))
                .then(function () {
                    return performRemoval(selection);
                })
                .then(function () {
                    removePeopleFromList(selection.selectedPeople);
                });
        }

        function exportPeople () {
            organizationOverviewPeopleService.exportPeople(getSelection(), getOrder());
        }

        function transferPeople () {
            var selection = getSelection();
            $uibModal.open({
                component: 'transferModal',
                resolve: {
                    selection: _.constant(selection)
                },
                windowClass: 'pivot_theme',
                size: 'md'
            }).result.then(function (copyContacts) {
                if (copyContacts === false) {
                    removePeopleFromList(selection.selectedPeople);
                }
            });
        }

        function archivePeople () {
            removePeople('ministries.people.archive_people_confirm', organizationOverviewPeopleService.archivePeople);
        }

        function deletePeople () {
            removePeople('ministries.people.delete_people_confirm', organizationOverviewPeopleService.deletePeople);
        }

        function clearSelection () {
            vm.selectAllValue = false;
            vm.multiSelection = {};
        }
    }
})();
