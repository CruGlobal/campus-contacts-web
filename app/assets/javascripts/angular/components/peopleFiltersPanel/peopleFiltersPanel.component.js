import template from './peopleFiltersPanel.html';
import './peopleFiltersPanel.scss';

angular.module('missionhubApp').component('peopleFiltersPanel', {
    controller: peopleFiltersPanelController,
    template: template,
    bindings: {
        filtersChanged: '&',
        organizationId: '<',
        surveyId: '<',
    },
});

function peopleFiltersPanelController(
    $scope,
    httpProxy,
    modelsService,
    peopleFiltersPanelService,
    _,
) {
    this.filters = null;
    this.filtersApplied = false;
    this.groupOptions = [];
    this.assignmentOptions = [];
    this.labelOptions = [];
    this.statusOptions = [];
    this.genderOptions = [];
    this.labelFilterCollapsed = true;
    this.assignedToFilterCollapsed = true;
    this.groupFilterCollapsed = true;
    this.statusFilterCollapsed = true;
    this.genderFilterCollapsed = true;

    this.$onInit = () => {
        $scope.$watch(
            '$ctrl.filters',
            (newFilters, oldFilters) => {
                if (!_.isEqual(newFilters, oldFilters)) {
                    this.filtersApplied = peopleFiltersPanelService.filtersHasActive(
                        getNormalizedFilters(),
                    );

                    sendFilters();
                }
            },
            true,
        );

        this.resetFilters();

        loadFilterStats();

        $scope.$on('massEditApplied', loadFilterStats);
    };

    this.resetFilters = () => {
        this.filters = {
            searchString: '',
            labels: {},
            assignedTos: {},
            groups: {},
            includeArchived: false,
        };
    };

    // Send the filters to this component's parent via the filtersChanged binding
    const sendFilters = () => {
        this.filtersChanged({ filters: getNormalizedFilters() });
    };

    const loadFilterStats = () => {
        return httpProxy
            .get(
                modelsService
                    .getModelMetadata('filter_stats')
                    .url.single(this.surveyId ? 'survey' : 'people'),
                {
                    organization_id: this.organizationId,
                    survey_id: this.surveyId,
                    include_unassigned: true,
                },
                {
                    errorMessage:
                        'error.messages.people_filters_panel.load_filter_stats',
                },
            )
            .then(httpProxy.extractModel)
            .then(stats => {
                this.labelOptions = stats.labels;
                this.assignmentOptions = stats.assigned_tos;
                this.groupOptions = stats.groups;
                this.statusOptions = stats.statuses;
                this.genderOptions = stats.genders;

                // Restrict the active filters to currently valid options
                // A filter could include a non-existent label, for example, if people were edited so that no one
                // has that label anymore
                this.filters.labels = _.pick(
                    this.filters.labels,
                    _.map(this.labelOptions, 'label_id'),
                );
                this.filters.assignedTos = _.pick(
                    this.filters.assignedTos,
                    _.map(this.assignmentOptions, 'person_id'),
                );
                this.filters.groups = _.pick(
                    this.filters.groups,
                    _.map(this.groupOptions, 'group_id'),
                );
            });
    };

    // Return the an array of an dictionary's keys that have a truthy value
    const getTruthyKeys = dictionary => {
        return _.chain(dictionary)
            .pickBy()
            .keys()
            .value();
    };

    const getNormalizedFilters = () => {
        return {
            searchString: this.filters.searchString,
            includeArchived: this.filters.includeArchived,
            labels: getTruthyKeys(this.filters.labels),
            assignedTos: getTruthyKeys(this.filters.assigned_tos),
            groups: getTruthyKeys(this.filters.groups),
            statuses: getTruthyKeys(this.filters.statuses),
            genders: getTruthyKeys(this.filters.genders),
        };
    };
}
