import _ from 'lodash';

angular
    .module('missionhubApp')
    .factory('peopleFiltersPanelService', peopleFiltersPanelService);

function peopleFiltersPanelService(httpProxy, modelsService) {
    return {
        // Determine whether a filters object contains any active filters or not
        filtersHasActive: function(filters) {
            return (
                Boolean(filters.searchString) ||
                filters.includeArchived === true ||
                _.keys(filters.labels).length > 0 ||
                _.keys(filters.assignedTos).length > 0 ||
                _.keys(filters.groups).length > 0 ||
                _.keys(filters.statuses).length > 0 ||
                _.keys(filters.permissions).length > 0 ||
                _.keys(filters.genders).length > 0 ||
                _.keys(filters.questions).length > 0 ||
                filters.includeArchived === true
            );
        },
        updateFilterCounts: function(orgId, surveyId) {
            return httpProxy
                .get(
                    modelsService
                        .getModelMetadata('filter_stats')
                        .url.single(surveyId ? 'survey' : 'people'),
                    {
                        organization_id: orgId,
                        survey_id: surveyId,
                        include_unassigned: true,
                    },
                    {
                        errorMessage:
                            'error.messages.people_filters_panel.load_filter_stats',
                    },
                )
                .then(httpProxy.extractModel)
                .then(stats => {
                    return stats.assigned_tos;
                });
        },
    };
}
