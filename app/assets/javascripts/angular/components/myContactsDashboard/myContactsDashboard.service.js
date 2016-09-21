/**
 * Created by eijeh on 9/2/16.
 */


(function () {

    'use strict';

    angular
        .module('missionhubApp')
        .factory('myContactsDashboardService', myContactsDashboardService);


    function myContactsDashboardService (httpProxy, apiEndPoint) {

        return {

            loadPeople: function () {
                return httpProxy.get(apiEndPoint.people.index, {
                    'page[limit]': 250,
                    include: 'phone_numbers,email_addresses,reverse_contact_assignments.organization,' +
                    'organizational_permissions',
                    'filters[assigned_tos]': 'me'
                });
            },

            loadPeopleReports: function (model) {
                return httpProxy.get(apiEndPoint.reports.people, {
                    period: model.period,
                    organization_ids: model.organization_ids,
                    people_ids: model.people_ids
                });
            },

            loadOrganizationReports: function (model) {
                return httpProxy.get(apiEndPoint.reports.organizations,
                    {
                        period: model.period,
                        organization_ids: model.organization_ids
                    });
            },

            loadOrganizations: function () {
                return httpProxy
                    .get(apiEndPoint.organizations.index, {
                        'page[limit]': 100,
                        order: 'active_people_count',
                        include: ''
                    });
            },

            updateUserPreference: function (model) {
                httpProxy.put(apiEndPoint.users.me, null, model);
            }
        };
    }

})();
