(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('myOrganizationsDashboardService', myOrganizationsDashboardService);


    function myOrganizationsDashboardService (httpProxy, apiEndPoint) {

        var myOrganizationsDashboardService = {
            loadGroups: function (params) {
                return httpProxy.get(apiEndPoint.groups.index, params || {});
            },

            loadSurveys: function (orgId) {
                return httpProxy.get(apiEndPoint.organizations.index + '/' + orgId, {
                    include: 'surveys'
                });
            }
        };

        return myOrganizationsDashboardService;
    }

})();
