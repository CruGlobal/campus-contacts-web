import _ from 'lodash';

angular
    .module('missionhubApp')
    .factory('peopleFiltersPanelService', peopleFiltersPanelService);

function peopleFiltersPanelService() {
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
                _.keys(filters.genders).length > 0 ||
                _.keys(filters.questions).length > 0 ||
                filters.includeArchived === true
            );
        },
    };
}
