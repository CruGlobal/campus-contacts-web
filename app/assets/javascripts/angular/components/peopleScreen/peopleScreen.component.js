import _ from 'lodash';

import './peopleScreen.scss';
import pencilIcon from '../../../../images/icons/pencil.svg';
import mergeIcon from '../../../../images/icons/merge.svg';
import emailIcon from '../../../../images/icons/email.svg';
import messageIcon from '../../../../images/icons/message.svg';
import downloadCsvIcon from '../../../../images/icons/downloadCsv.svg';
import transferIcon from '../../../../images/icons/transfer.svg';
import archiveIcon from '../../../../images/icons/archive.svg';
import deleteIcon from '../../../../images/icons/delete.svg';
import closeIcon from '../../../../images/icons/close.svg';

import template from './peopleScreen.html';

angular.module('missionhubApp').component('peopleScreen', {
    controller: peopleScreenController,
    bindings: {
        org: '<',
        loaderService: '<',
        surveyId: '<',
        questions: '<',
        queryFilters: '<',
    },
    require: {
        organizationOverview: '^',
    },
    template: template,
});

function peopleScreenController(
    $rootScope,
    $scope,
    $filter,
    $uibModal,
    confirmModalService,
    peopleScreenService,
    personService,
    peopleFiltersPanelService,
    organizationOverviewTeamService,
    loggedInPerson,
    ProgressiveListLoader,
    RequestDeduper,
) {
    const listLoader = new ProgressiveListLoader({
        modelType: 'person',
        requestDeduper: new RequestDeduper(),
        errorMessage:
            'error.messages.organization_overview_people.load_people_chunk',
    });

    this.people = [];
    this.multiSelection = {};
    this.filters = {};
    this.loadedAll = false;
    this.busy = false;
    this.selectedCount = 0;
    this.totalCount = 0;
    this.$rootScope = $rootScope;

    // Icons
    this.pencilIcon = pencilIcon;
    this.mergeIcon = mergeIcon;
    this.emailIcon = emailIcon;
    this.messageIcon = messageIcon;
    this.downloadCsvIcon = downloadCsvIcon;
    this.transferIcon = transferIcon;
    this.archiveIcon = archiveIcon;
    this.deleteIcon = deleteIcon;
    this.closeIcon = closeIcon;

    // represents if the user has checked the "Select All" checkbox
    this.selectAllValue = false;

    // Define the columns that can be selected as sort keys
    // The "getSortKey" method returns the value that a person should be sorted by when sorting by that column
    this.columns = [
        {
            name: 'name',
            cssClass: 'name-column',
            label: 'ministries.people.name',
            sortable: true,
            getSortKey: person => {
                return [
                    (person.last_name || '').toLowerCase(),
                    (person.first_name || '').toLowerCase(),
                ];
            },
            orderFields: ['last_name', 'first_name'],
        },
        {
            name: 'gender',
            cssClass: 'detail-column gender-column',
            label: 'ministries.people.gender',
            sortable: true,
            getSortKey: person => {
                return person.gender;
            },
            orderFields: ['gender', 'last_name', 'first_name'],
        },
        {
            name: 'assignment',
            cssClass: 'detail-column assigned-to-column',
            label: 'assignments.assignment',
            sortable: false,
        },
        {
            name: 'status',
            cssClass: 'detail-column status-column',
            label: 'ministries.people.status',
            sortable: true,
            getSortKey: person => {
                const orgPermission = personService.getOrgPermission(
                    person,
                    this.org.id,
                );

                if (!orgPermission || orgPermission.archive_date !== null)
                    return 'Archived';

                return personService.getFollowupStatus(person, this.org.id);
            },
            orderFields: [
                'organizational_permissions.followup_status',
                'last_name',
                'first_name',
            ],
        },
    ];

    this.defaultSortOrder = { column: this.columns[0], direction: 'asc' };

    let unsubscribe = null;

    this.$onInit = () => {
        if (this.surveyId) addLastSurveyColumn();

        unsubscribe = $rootScope.$on('personCreated', (event, person) => {
            onNewPerson(person);
        });

        this.sortOrder = _.clone(this.defaultSortOrder);
        this.isAdmin = loggedInPerson.isAdminAt(this.org);

        $scope.$watch(
            '$ctrl.multiSelection',
            () => {
                this.selectedCount = selectedCount();
            },
            true,
        );
    };

    this.$onDestroy = () => {
        unsubscribe();
    };

    const addLastSurveyColumn = () => {
        this.columns.push({
            name: 'lastSurvey',
            cssClass: 'detail-column assigned-to-column',
            label: 'ministries.people.lastSurvey',
            sortable: true,
            getSortKey: person => {
                const lastSurvey = personService.getLastSurvey(person);
                if (!lastSurvey) return '1969-12-12 00:00:00'; //Force null to buttom of list
                return lastSurvey;
            },
            orderFields: [
                'answer_sheets.updated_at',
                'last_name',
                'first_name',
            ],
        });
    };

    const selectedCount = () => {
        // because multiSelection is only a list of the loaded records,
        // we need to count the ones that are explicitly un-selected when
        // select all is checked
        const unselected = getUnselectedPeople().length;

        // has the user unselected all of the records?
        if (unselected === this.totalCount) {
            this.selectAllValue = false;
        }

        if (this.selectAllValue) {
            return this.totalCount - unselected;
        }
        return getSelectedPeople().length;
    };

    this.loadPersonPage = () => {
        this.busy = true;
        const orgId = this.org.id;

        // Generate the sort order list
        return peopleScreenService
            .loadMoreOrgPeople(
                orgId,
                this.filters,
                getOrder(),
                listLoader,
                this.loaderService,
                this.surveyId,
            )
            .then(resp => {
                const oldPeople = this.people;
                this.people = resp.list;
                this.loadedAll = resp.loadedAll;
                this.totalCount = resp.total;
                // Set the selected state of all of the new people
                _.differenceBy(this.people, oldPeople, 'id').forEach(person => {
                    this.multiSelection[person.id] = this.selectAllValue;
                });
            })
            .finally(() => {
                this.busy = false;
            });
    };

    // Respond to the creation of a new person by potentially adding it to the person list, updating counts, etc.
    const onNewPerson = person => {
        // If filters are applied, then refresh the list because the new person may or may not be included
        // in the person list. If no filters applied, simply add it to the person list.
        if (peopleFiltersPanelService.filtersHasActive(this.filters)) {
            resetList();
            this.loadPersonPage();
        } else {
            this.people.push(person);
            this.totalCount++;
            this.multiSelection[person.id] = this.selectAllValue;
        }

        // Update the people count shown in the people tab
        if (this.organizationOverview.people) {
            this.organizationOverview.people.length++;
            // When a new person is added, check if the Team count has changed and update the UI
            organizationOverviewTeamService
                .loadOrgTeamCount(this.org.id)
                .then(resp => (this.organizationOverview.team.length = resp));
        }
        // Emit to tell the peopleFilterPanel component that the assigned to count could have changed
        $rootScope.$emit('updateFilterCount');
    };

    // Return an array of the ids of all people with the specified selection state (true for selected, false for
    // unselected)
    const getPeopleByState = state => {
        return _.chain(this.multiSelection)
            .pickBy(selected => {
                return selected === state;
            })
            .keys()
            .value();
    };

    // Return an array of the ids of all selected people
    const getSelectedPeople = () => {
        return getPeopleByState(true);
    };

    // Return an array of the ids of all selected people
    const getUnselectedPeople = () => {
        return getPeopleByState(false);
    };

    const resetList = () => {
        this.people = [];
        listLoader.reset();
        this.loadedAll = false;
        this.selectAllValue = false;
        this.multiSelection = {};
    };

    this.filtersChanged = newFilters => {
        this.filters = newFilters;
        resetList();
        this.loadPersonPage();
    };

    this.setSortColumn = column => {
        if (this.sortOrder.column === column) {
            if (this.sortOrder.direction === 'asc') {
                this.sortOrder.direction = 'desc';
            } else if (this.sortOrder.direction === 'desc') {
                this.sortOrder = _.clone(this.defaultSortOrder);
            }
        } else {
            this.sortOrder.column = column;
            this.sortOrder.direction = 'asc';
        }

        // Reload the list of people using the new sort order
        resetList();
        this.loadPersonPage();
    };

    this.selectAll = () => {
        this.people.forEach(person => {
            this.multiSelection[person.id] = this.selectAllValue;
        });
    };

    // Get the current selection in a standard form
    const getSelection = () => {
        return {
            orgId: this.org.id,
            filters: this.filters,
            selectedPeople: getSelectedPeople(),
            unselectedPeople: getUnselectedPeople(),
            totalSelectedPeople: this.selectedCount,
            allSelected: this.selectAllValue,
            allIncluded: this.loadedAll,
        };
    };

    // Get the current sort order
    const getOrder = () => {
        return this.sortOrder.column.orderFields.map(fieldName => {
            return { field: fieldName, direction: this.sortOrder.direction };
        });
    };

    // Open a modal to mass-edit all selected people
    this.massEdit = () => {
        $uibModal
            .open({
                component: 'massEdit',
                resolve: {
                    selection: _.constant(getSelection()),
                    surveyId: () => this.surveyId,
                },
                windowClass: 'pivot_theme',
                size: 'md',
            })
            .result.then(() => {
                $scope.$broadcast('massEditApplied');

                // Determine whether any filters are applied
                if (!peopleFiltersPanelService.filtersHasActive(this.filters)) {
                    // When there are no filters, we only need to make sure that all the people that people in the list
                    // are assigned to are loaded
                    peopleScreenService.loadAssignedTos(
                        this.people,
                        this.org.id,
                    );
                    return;
                }

                // When there are filters, we need to reload the entire people list because those people might not match
                // the filter anymore and we are currently choosing not to do client-side filtering

                const originalSelectAllValue = this.selectAllValue;
                const originalMultiSelection = this.multiSelection;

                // Empty and reload the people list
                resetList();
                this.loadPersonPage().then(() => {
                    // Restore the select all value and the selection states of all people that are still loaded

                    // Ignore original selection states that do not match a loaded person
                    const relevantOriginalSelections = _.pick(
                        originalMultiSelection,
                        _.map(this.people, 'id'),
                    );

                    // Copy those selections to the current selection
                    _.extend(this.multiSelection, relevantOriginalSelections);

                    // Keep the select all checkbox selected if it was originally selected and some people are selected
                    this.selectAllValue =
                        originalSelectAllValue &&
                        getSelectedPeople().length > 0;
                });
            });
    };

    this.sendMessage = medium => {
        $uibModal.open({
            component: 'messageModal',
            resolve: {
                medium: _.constant(medium),
                selection: _.constant(getSelection()),
                surveyId: () => this.surveyId,
            },
            windowClass: 'pivot_theme',
            size: 'md',
        });
    };

    // Remove the specified people from the people list in the UI
    const removePeopleFromList = peopleIds => {
        // Partition loaded people by whether or not they are removed
        const partition = _.partition(this.people, person => {
            return _.includes(peopleIds, person.id);
        });
        const removedPeople = partition[0];
        const remainingPeople = partition[1];

        // Update the people list and count
        this.people = remainingPeople;
        this.totalCount -= removedPeople.length;
        listLoader.reset(this.people);

        // Update the people count shown in the people tab
        if (this.organizationOverview.people) {
            this.organizationOverview.people.length -= removedPeople.length;
            // When a person is removed, check if the team count has been changed and update the UI to match it
            organizationOverviewTeamService
                .loadOrgTeamCount(this.org.id)
                .then(resp => (this.organizationOverview.team.length = resp));
        }

        // Remove the selection state of removed people
        removedPeople.forEach(person => {
            delete this.multiSelection[person.id];
        });

        // Instruct the infinite scroller to check whether more people should be loaded because after
        // removing some people, the list will be shorter and may now be at the bottom. However, do this in
        // the next digest cycle after all of the removed people have been removed from the UI.
        $scope.$applyAsync(() => {
            $scope.$emit('checkInfiniteScroll');
        });
        $scope.$broadcast('massEditApplied');
        // Emit to tell the peopleFilterPanel component that the assigned to count could have changed
        $scope.$emit('updateFilterCount');
    };

    // Remove the selected people
    // This is an abstract method that can both archive and remove people
    const removePeople = (message, performRemoval) => {
        const selection = getSelection();
        let transformedMessage = message;

        // look to see if the user is the only one selected, if so, allow them to archive self
        if (_.isEqual(selection.selectedPeople, [loggedInPerson.person.id])) {
            transformedMessage = 'ministries.people.remove_self_confirm';
        } else if (selection.allSelected && !selection.allIncluded) {
            // if everyone is selected, unselectedPeople will only be used if not everyone is loaded
            // and we know if everyone is loaded by checkin allIncluded
            if (
                _.indexOf(
                    selection.unselectedPeople,
                    loggedInPerson.person.id,
                ) === -1
            ) {
                selection.unselectedPeople = _.union(
                    selection.unselectedPeople,
                    [loggedInPerson.person.id],
                );
                selection.totalSelectedPeople = selectedCount() - 1;
            }
        } else if (
            _.indexOf(selection.selectedPeople, loggedInPerson.person.id) !== -1
        ) {
            selection.selectedPeople = _.pull(
                selection.selectedPeople,
                loggedInPerson.person.id,
            );
            selection.totalSelectedPeople = selectedCount() - 1;
        }
        transformedMessage = $filter('t')(transformedMessage, {
            contact_count: selection.totalSelectedPeople,
        });
        confirmModalService
            .create(transformedMessage)
            .then(() => {
                return performRemoval(selection);
            })
            .then(() => {
                removePeopleFromList(selection.selectedPeople);
            });
    };

    this.exportPeople = () => {
        peopleScreenService.exportPeople(
            this.org.id,
            getSelection(),
            getOrder(),
            this.surveyId,
        );
    };

    this.transferPeople = () => {
        const selection = getSelection();
        $uibModal
            .open({
                component: 'transferModal',
                resolve: {
                    selection: _.constant(selection),
                    surveyId: () => this.surveyId,
                },
                windowClass: 'pivot_theme',
                size: 'md',
            })
            .result.then(copyContacts => {
                if (copyContacts === false) {
                    removePeopleFromList(selection.selectedPeople);
                }
            });
    };

    this.archivePeople = () => {
        removePeople(
            'ministries.people.archive_people_confirm',
            peopleScreenService.archivePeople,
        );
    };

    this.deletePeople = () => {
        removePeople(
            'ministries.people.delete_people_confirm',
            peopleScreenService.deletePeople,
        );
    };

    this.clearSelection = () => {
        this.selectAllValue = false;
        this.multiSelection = {};
    };
}
