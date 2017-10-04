/**
 * Created by eijeh on 9/2/16.
 */

(function () {
    'use strict';

    angular
        .module('missionhubApp')
        .factory('myPeopleDashboardService', myPeopleDashboardService);

    function myPeopleDashboardService (httpProxy, modelsService, periodService, _) {
        var myPeopleDashboardService = {
            loadPeople: function (params) {
                return httpProxy.get(modelsService.getModelMetadata('person').url.all, params || {}, {
                    errorMessage: 'error.messages.my_people_dashboard.load_people'
                });
            },

            loadPeopleReports: function (model) {
                return httpProxy.get(modelsService.getModelMetadata('person_report').url.all, {
                    period: periodService.getPeriod(),
                    organization_ids: model.organization_ids.join(','),
                    people_ids: model.people_ids.join(',')
                }, {
                    errorMessage: 'error.messages.my_people_dashboard.load_reports'
                });
            },

            loadOrganizations: function (params) {
                return httpProxy.get(modelsService.getModelMetadata('organization').url.all, _.extend({
                    order: 'active_people_count',
                    include: ''
                }, params), {
                    errorMessage: 'error.messages.my_people_dashboard.load_orgs'
                }).then(httpProxy.extractModels);
            }
        };

        return myPeopleDashboardService;
    }
})();
