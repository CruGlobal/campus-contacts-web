(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('reportsService', reportsService);

    // This service contains action logic that is shared across components
    function reportsService ($q, httpProxy, modelsService, JsonApiDataStore, periodService, _) {
        // Create an empty report for the specified report type and id
        function createReport (type, reportId) {
            var record = JsonApiDataStore.store.sync({
                data: {
                    type: type,
                    id: reportId,
                    attributes: {
                        contact_count: 0,
                        uncontacted_count: 0,
                        placeholder: true,
                        interactions: []
                    }
                }
            });
            record._placeHolder = true;
            return record;
        }

        // Calculate the id of the report for the specified organization
        function calculateOrganizationReportId (organizationId) {
            return [organizationId, periodService.getPeriod()].join('-');
        }

        // Calculate the id of the report for the specified person in the specified organization
        function calculatePersonReportId (organizationId, personId) {
            return [organizationId, personId, periodService.getPeriod()].join('-');
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
                return findOrCreateReport('organization_report', calculateOrganizationReportId(organizationId));
            },

            // Find and return the report for the given person
            lookupPersonReport: function (organizationId, personId) {
                return findOrCreateReport('person_report', calculatePersonReportId(organizationId, personId));
            },

            // Load the person report for the given person
            loadPersonReport: function (organizationId, personId) {
                // Try to find the report
                var reportId = calculatePersonReportId(organizationId, personId);
                var report = findReport('person_report', reportId);

                if (report) {
                    // The report is already loaded, so simply return it
                    return $q.resolve(report);
                }

                // Load the report and return it
                return httpProxy
                    .get(modelsService.getModelMetadata('person_report').url.all, {
                        period: periodService.getPeriod(),
                        organization_ids: organizationId.toString(),
                        people_ids: personId.toString()
                    }, {
                        errorMessage: 'error.messages.reports.load_person_report'
                    })
                    .then(httpProxy.extractModels)
                    .then(function (people) {
                        return people[0];
                    });
            },

            // Load reports for specific people and organizations
            loadMultiplePeopleReports: function (orgs, people) {
                return httpProxy.get(modelsService.getModelMetadata('person_report').url.all, {
                    period: periodService.getPeriod(),
                    organization_ids: _.map(orgs, 'id').join(','),
                    people_ids: _.map(people, 'id').join(',')
                }, {
                    errorMessage: 'error.messages.my_people_dashboard.load_reports'
                });
            },

            // Load organization reports for the given organizations
            loadOrganizationReports: function (orgs) {
                var organizationIds = _.map(orgs, 'id');

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

                    // The report needs to be loaded if the report could not be found or if it is just a placeholder
                    return !report || report._placeHolder;
                });

                if (unloadedOrgIds.length === 0) {
                    // All requested organization report are already loaded, so no network request is necessary
                    return $q.resolve(lookupReports());
                }

                return httpProxy.get(modelsService.getModelMetadata('organization_report').url.all, {
                    period: periodService.getPeriod(),
                    organization_ids: unloadedOrgIds.join(',')
                }, {
                    errorMessage: 'error.messages.reports.load_org_reports'
                }).then(function () {
                    return lookupReports();
                });
            },

            // Return the number of interactions of a specific type in a particular report
            getInteractionCount: function (report, interactionTypeId) {
                var interaction = report && _.find(report.interactions, { interaction_type_id: interactionTypeId });
                return _.isNil(interaction) ? '-' : interaction.interaction_count;
            },

            // Add a new interaction to a report
            incrementReportInteraction: function (report, interactionTypeId) {
                var interaction = _.find(report.interactions, {
                    interaction_type_id: interactionTypeId
                });
                if (interaction) {
                    interaction.interaction_count++;
                } else {
                    report.interactions.push({
                        interaction_type_id: interactionTypeId,
                        interaction_count: 1
                    });
                }
            }
        };

        return reportsService;
    }
})();
