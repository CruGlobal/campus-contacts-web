(function () {
    angular
        .module('missionhubApp')
        .factory('reportsService', reportsService);

    // This service contains action logic that is shared across components
    function reportsService ($q, JsonApiDataStore, periodService, httpProxy, apiEndPoint) {
        // Create an empty report for the specified report type and id
        function createReport (type, reportId) {
            return JsonApiDataStore.store.sync({
                data: [{
                    type: type,
                    id: reportId,
                    attributes: {interactions: []}
                }]
            })[0];
        }

        // Create an empty report for the specified report type and id
        function findReport (type, reportId) {
            return JsonApiDataStore.store.find(type, reportId);
        }

        function findOrCreateReport (type, reportId) {
            return findReport(type, reportId) || createReport(type, reportId);
        }

        var reportsService = {
            // Find and return the report for the given organization
            lookupOrganizationReport: function (organizationId) {
                var reportId = [organizationId, periodService.getPeriod()].join('-');
                return findOrCreateReport('organization_report', reportId);
            },

            // Find and return the report for the given organization
            lookupPersonReport: function (organizationId, personId) {
                var reportId = [organizationId, personId, periodService.getPeriod()].join('-');
                return findOrCreateReport('person_report', reportId);
            },

            // Load organization reports for the given organizations
            loadOrganizationReports: function (organizationIds) {
                // Return an array of the organization reports for the requested organization ids. Any reports that are
                // not yet loaded will be represented as a null value.
                function lookupReports () {
                    return organizationIds.map(function (organizationId) {
                        return reportsService.lookupOrganizationReport(organizationId);
                    });
                }

                // Determine which organization reports have not been loaded yet and actually need to be loaded
                var unloadedOrgIds = organizationIds.filter(function (organizationId) {
                    var report = reportsService.lookupOrganizationReport(organizationId);
                    // if there is no data we need to check if it is just a placeholder
                    return !report || (report.interactions && report.interactions.length === 0);
                });

                if (unloadedOrgIds.length === 0) {
                    // All requested organization report are already loaded, so no network request is necessary
                    return $q.resolve(lookupReports());
                }

                return httpProxy.get(apiEndPoint.reports.organizations, {
                    period: periodService.getPeriod(),
                    organization_ids: unloadedOrgIds.join(',')
                }).then(function () {
                    return lookupReports();
                });
            }
        };

        return reportsService;
    }
})();
