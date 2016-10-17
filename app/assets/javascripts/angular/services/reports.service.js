(function () {
    angular
        .module('missionhubApp')
        .factory('reportsService', reportsService);

    // This service contains action logic that is shared across components
    function reportsService (JsonApiDataStore, periodService, httpProxy, apiEndPoint) {
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
            lookupOrganizationReport: function (organizationId) {
                return lookupReport('organization_report', [organizationId, periodService.getPeriod()].join('-'));
            },

            // Find and return the report for the given organization
            lookupPersonReport: function (organizationId, personId) {
                return lookupReport('person_report', [organizationId, personId, periodService.getPeriod()].join('-'));
            },

            loadOrganizationReports: function (organization_ids) {
                return httpProxy.get(apiEndPoint.reports.organizations, {
                    period: periodService.getPeriod(),
                    organization_ids: organization_ids.join(',')
                });
            }
        };
    }
})();
