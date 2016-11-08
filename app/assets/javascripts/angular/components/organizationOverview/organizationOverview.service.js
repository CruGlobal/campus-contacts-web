(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewService', organizationOverviewService);

    function organizationOverviewService ($q, httpProxy, modelsService, _) {
        return {
            // Load an organization's relationships (groups and surveys)
            loadOrgRelations: function (org) {
                // Determine which relations are not yet loaded
                var include = ['groups', 'surveys'].filter(function (relation) {
                    // Include this relation only if contains placeholder relations that need to be fully loaded
                    return _.findIndex(org[relation], { _placeHolder: true }) !== -1;
                });

                // Load the missing relations, if any
                if (include.length === 0) {
                    return $q.resolve();
                }
                return httpProxy.get(modelsService.getModelMetadata('organization').url.single(org.id), {
                    include: include.join(',')
                });
            },

            // Load an organization's sub-orgs
            loadOrgSuborgs: function (org) {
                return httpProxy.get(modelsService.getModelMetadata('organization').url.all, {
                    'filters[parent_ids]': org.id,
                    include: 'groups,surveys'
                });
            }
        };
    }

})();
