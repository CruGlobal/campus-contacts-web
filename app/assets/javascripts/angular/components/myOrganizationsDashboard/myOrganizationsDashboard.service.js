(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('myOrganizationsDashboardService', myOrganizationsDashboardService);

    function myOrganizationsDashboardService (httpProxy, JsonApiDataStore, loggedInPerson, _) {
        return {
            // Return an array of all loaded root organizations
            getRootOrganizations: function () {
                // Find all of the organizations that the user is a team member of
                return _.chain(JsonApiDataStore.store.findAll('organizational_permission'))
                    .filter(function (permission) {
                        // 1 is the admin permission, and 4 is the user permission
                        return permission.person_id === loggedInPerson.person.id &&
                               _.includes([1, 4], permission.permission_id);
                    })
                    .map('organization')
                    .value();
            }
        };
    }
})();
