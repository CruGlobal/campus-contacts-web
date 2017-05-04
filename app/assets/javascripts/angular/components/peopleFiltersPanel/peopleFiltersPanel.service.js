(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('peopleFiltersPanelService', peopleFiltersPanelService);

    function peopleFiltersPanelService (_) {
        return {
            // Determine whether a filters object contains any active filters or not
            filtersHasActive: function (filters) {
                return filters.searchString || _.keys(filters.labels).length ||
                    _.keys(filters.assignedTos).length || _.keys(filters.groups).length;
            }
        };
    }
})();
