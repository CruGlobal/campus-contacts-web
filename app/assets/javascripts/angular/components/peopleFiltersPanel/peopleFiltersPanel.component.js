import template from './peopleFiltersPanel.html';
import './peopleFiltersPanel.scss';

angular.module('missionhubApp').component('peopleFiltersPanel', {
    controller: peopleFiltersPanelController,
    template: template,
    bindings: {
        filtersChanged: '&',
        organizationId: '<',
        surveyId: '<',
        questions: '<',
    },
});

function peopleFiltersPanelController(
    $rootScope,
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
    this.questionOptions = [];
    this.answerMatchingOptions = [];

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

        $rootScope.$on('personModified', loadFilterStats);
        $rootScope.$on('massEditApplied', loadFilterStats);
    };

    this.resetFilters = () => {
        this.filters = {
            searchString: '',
            labels: {},
            assignedTos: {},
            statuses: {},
            groups: {},
            questions: {},
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
                this.questionOptions = stats.questions;

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

    this.findStats = ({ id }) =>
        this.questionOptions.find(({ question_id }) => question_id === id);

    const emptyArrayToUndefined = value =>
        value.length === 0 ? undefined : value;

    const getFiltersFromObj = _.flow([
        _.pickBy, // keep truthy key/value pairs
        Object.keys, // get array of keys
        emptyArrayToUndefined,
    ]);

    const getNormalizedFilters = () => {
        return {
            searchString: this.filters.searchString,
            includeArchived: this.filters.includeArchived,
            labels: getFiltersFromObj(this.filters.labels),
            assignedTos: getFiltersFromObj(this.filters.assigned_tos),
            groups: getFiltersFromObj(this.filters.groups),
            statuses: getFiltersFromObj(this.filters.statuses),
            genders: getFiltersFromObj(this.filters.genders),
            questions: _.flow([
                questions =>
                    _.mapValues(questions, answers =>
                        getFiltersFromObj(
                            typeof answers === 'string'
                                ? { [answers]: !!answers } // becomes falsy if answer is empty string
                                : answers,
                        ),
                    ),
                _.pickBy, // keep truthy key/value pairs
            ])(this.filters.questions),
            answerMatchingOptions: _.pickBy(this.filters.answerMatchingOptions),
        };
    };
}
