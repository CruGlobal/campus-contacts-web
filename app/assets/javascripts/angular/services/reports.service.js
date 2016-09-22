(function () {
    angular
        .module('missionhubApp')
        .factory('reportsService', reportsService);

    // This service contains action logic that is shared across components
    function reportsService (JsonApiDataStore) {
        function lookupReport (type, reportId) {
            return JsonApiDataStore.store.find(type, reportId) ||
                JsonApiDataStore.store.sync({
                    data: [{
                        type: type,
                        id: reportId,
                        attributes: {interactions: []}
                    }]
                })[0];
        }

        return {
            // Find and return the report for the given organization
            lookupOrganizationReport: function (organizationId, period) {
                return lookupReport('organization_report', [organizationId, period].join('-'));
            },

            // Find and return the report for the given organization
            lookupPersonReport: function (organizationId, personId, period) {
                return lookupReport('person_report', [organizationId, personId, period].join('-'));
            }
        };
    }
})();
