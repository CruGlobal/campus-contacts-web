(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('organizationOverviewService', organizationOverviewService);

    function organizationOverviewService (httpProxy, apiEndPoint) {
        return {
            // Load an organization's relationships (groups and surveys)
            loadOrgRelations: function (org) {
                return httpProxy.get(apiEndPoint.organizations.index + '/' + org.id, {
                    include: 'groups,surveys'
                });
            },

            // Load an organization's sub-orgs
            loadOrgSuborgs: function (org) {
                return httpProxy.get(apiEndPoint.organizations.index, {
                    'filters[parent_ids]': org.id
                });
            },

            // Load an organization's people
            loadOrgPeople: function (org) {
                return httpProxy.get(apiEndPoint.people.index, {
                    include: 'organizational_permissions.organization',
                    organization_id: org.id
                });
            }
        };
    }

})();
